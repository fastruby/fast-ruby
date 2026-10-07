# Builds the results site from a run of script/run_cross_ruby.rb, where every build of a benchmark ran on one machine:
#
#   ruby script/build_results_site.rb <results_dir> [output_dir]
#
# output_dir defaults to _site/. Result files are found at any depth, so both a local folder and CI's merged artifacts work.
# The site has two views, both from that run:
#
# - "Across Rubies": i/s on every build, with the reference build's passes showing how steady that machine was.
# - "Does it hold?": does the report the file claims is fastest win on this Ruby and build?
require "fileutils"
require "json"

module ResultsSite
  REPO_URL = "https://github.com/fastruby/fast-ruby".freeze
  ENGINES = %w[ruby jruby truffleruby].freeze
  TEMPLATE = File.expand_path("results_site.html", __dir__)

  # Over a billion iterations per second is under 1 ns per iteration: the JIT
  # most likely removed the work (TruffleRuby reports hundreds of billions).
  SUSPECT_IPS = 1e9

  # How much the reference build's i/s may vary over its passes (standard deviation / mean) before a benchmark is marked noisy.
  # When the typical benchmark of a run is over it, the page warns that small differences between Rubies may be the machine.
  # On GitHub runners (first run, 2026-10-06) the typical benchmark varied 2.3% and 7 of 78 went over 5%.
  GATE = 0.05

  # Sections come from the folder under code/, in this order.
  # A folder not listed here is shown after these, with its name capitalized.
  SECTIONS = {
    "general"        => "General",
    "method"         => "Method Invocation",
    "array"          => "Array",
    "enumerable"     => "Enumerable",
    "date"           => "Date",
    "hash"           => "Hash",
    "proc-and-block" => "Proc & Block",
    "string"         => "String",
    "time"           => "Time",
    "range"          => "Range",
    "bigdecimal"     => "BigDecimal"
  }.freeze

  module_function

  def build(results_dir, output_dir)
    reports = load_reports(results_dir)
    abort "No results from script/run_cross_ruby.rb found in #{results_dir}" if reports.empty?
    across_rubies = across_rubies_data(reports)
    does_it_hold = does_it_hold_data(does_it_hold_reports(reports))

    FileUtils.rm_rf(output_dir)
    FileUtils.mkdir_p(output_dir)
    File.write(File.join(output_dir, "index.html"), render(does_it_hold, across_rubies))
    File.write(File.join(output_dir, "does-it-hold.json"), JSON.generate(does_it_hold))
    File.write(File.join(output_dir, "across-rubies.json"), JSON.generate(across_rubies))
    puts "#{across_rubies[:benchmarks].size} benchmarks on #{across_rubies[:meta][:labels].size} builds"
    puts "Built into #{output_dir}"
  end

  # Only results from script/run_cross_ruby.rb, which have a pass number: anything else under the folder (a site built there earlier, another artifact, its order files) is left out.
  def load_reports(dir)
    reports = Dir[File.join(dir, "**", "*.json")].sort.map { |path| JSON.parse(File.read(path)) }
    reports.select { |r| r.is_a?(Hash) && r["entries"].is_a?(Array) && r["label"] && r["pass"] }
  end

  # "Does it hold?" from a cross-Ruby run: every build's result, and for the reference build, which ran many times, its pass in the middle of the run.
  def does_it_hold_reports(reports)
    refs, others = reports.partition { |r| r["reference"] }
    middle = refs.group_by { |r| [r["benchmark"], r["part"]] }.values.map { |rs| rs.sort_by { |r| r["pass"] }[rs.size / 2] }
    others + middle
  end

  # The claim is the first report: the lint guarantees the claimed one (the
  # report calling `fastest`, `faster` or `fast`) is listed first. A tie is
  # benchmark-ips' "same-ish": the i/s +- error ranges overlap, with the same
  # comparison as Benchmark::IPS::Stats::StatsMetric#overlaps?.
  def verdict(entries, claim)
    sorted = entries.sort_by { |e| -e["ips"] }
    top = sorted.first
    claimed = entries.find { |e| e["name"] == claim }
    suspect = entries.any? { |e| e["ips"] > SUSPECT_IPS }
    return { state: "na", suspect: suspect } unless claimed

    if claimed.equal?(top)
      second = sorted[1]
      if second.nil? || overlaps?(top, second)
        { state: "eq", suspect: suspect }
      else
        { state: "ok", ratio: top["ips"] / second["ips"], suspect: suspect }
      end
    elsif overlaps?(claimed, top)
      { state: "eq", suspect: suspect }
    else
      { state: "no", ratio: top["ips"] / claimed["ips"], winner: top["name"], suspect: suspect }
    end
  end

  def overlaps?(a, b)
    a["ips"] + a["error"] > b["ips"] - b["error"] && a["ips"] - a["error"] < b["ips"] + b["error"]
  end

  # Every build of a benchmark ran on one machine, recorded per benchmark.
  def does_it_hold_data(reports)
    labels = reports.map { |r| r["label"] }.uniq.sort_by { |l| label_sort_key(l) }
    grouped = reports.group_by { |r| [r["benchmark"], r["part"]] }
    multi_part = grouped.keys.group_by(&:first).select { |_, parts| parts.size > 1 }.keys

    benchmarks = grouped.map do |(file, part), runs|
      names = names_of(runs)
      b = describe(file, part, names, multi_part).merge(runs: runs.to_h { |r| [r["label"], run_data(r, names)] })
      b[:cpu] = runs.first.dig("environment", "cpu")
      b
    end

    { meta: meta(reports, labels), benchmarks: in_order(benchmarks) }
  end

  # The run with the most reports has them all; older Rubies can skip a
  # report guarded by RUBY_VERSION.
  def names_of(runs)
    runs.max_by { |r| r["entries"].size }["entries"].map { |e| e["name"] }
  end

  def describe(file, part, names, multi_part)
    title = title_for(names)
    title += " (part #{part})" if multi_part.include?(file)
    { file: file, part: part, title: title, section: section_for(file), names: names }
  end

  def in_order(benchmarks)
    order = SECTIONS.values
    benchmarks.sort_by! { |b| [order.index(b[:section]) || order.size, b[:section], b[:file], b[:part]] }
    # Two files with the same report labels get their file name added.
    benchmarks.group_by { |b| b[:title] }.each_value do |same|
      same.each { |b| b[:title] += " (#{File.basename(b[:file])})" } if same.size > 1
    end
    benchmarks
  end

  # Across Rubies. Every build of a benchmark ran on one machine (one shard), and the reference build ran first, between the others and last.
  # The page shows i/s as measured.
  # The reference's passes show how steady the machine was: it is the same code every time, so how much its i/s varies is the machine.
  # Correcting the other builds by the reference's speed at the time was tried and dropped: on GitHub runners and in local pilots it made the lines jumpier, since the variation was noise, not drift.
  def across_rubies_data(reports)
    labels = reports.map { |r| r["label"] }.uniq.sort_by { |l| label_sort_key(l) }
    reference = reports.find { |r| r["reference"] }&.fetch("label")
    grouped = reports.group_by { |r| [r["benchmark"], r["part"]] }
    multi_part = grouped.keys.group_by(&:first).select { |_, parts| parts.size > 1 }.keys

    benchmarks = grouped.map do |(file, part), runs|
      names = names_of(runs)
      passes = runs.select { |r| r["reference"] }
      # The reference's usable i/s per report: suspect (or zero) passes left out.
      ref_ips = names.map { |n| passes.filter_map { |r| e = entry(r, n); e["ips"] if e && e["ips"].positive? && e["ips"] <= SUSPECT_IPS } }
      builds = runs.reject { |r| r["reference"] }.to_h { |r| [r["label"], cross_run(r, names, ref_ips)] }
      builds[reference] = reference_run(passes, names, ref_ips) if reference && passes.any?
      moved = variation(ref_ips)
      describe(file, part, names, multi_part).merge(
        shard: runs.first["shard"],
        cpu: runs.first.dig("environment", "cpu"),
        reference_passes: passes.size,
        variation: moved&.round(4),
        noisy: !moved.nil? && moved > GATE,
        runs: builds
      )
    end

    { meta: cross_meta(reports, labels, reference, benchmarks), benchmarks: in_order(benchmarks) }
  end

  def entry(report, name)
    report["entries"].find { |e| e["name"] == name }
  end

  # Per report: [i/s, error, relative to the reference's median]. Relative is nil for a suspect or zero result, or a report the reference does not have.
  def cross_run(report, names, ref_ips)
    entries = names.each_with_index.map do |name, i|
      e = entry(report, name) or next nil
      rel = ref_ips[i].empty? || !e["ips"].positive? || e["ips"] > SUSPECT_IPS ? nil : (e["ips"] / median(ref_ips[i])).round(4)
      [e["ips"].round(3), e["error"].to_f.round(1), rel]
    end
    { entries: entries, pass: report["pass"] }
  end

  # The reference itself: its median pass, 1.0 relative to itself.
  def reference_run(passes, names, ref_ips)
    entries = names.each_with_index.map do |name, i|
      es = passes.filter_map { |r| entry(r, name) }
      next nil if es.empty?

      usable = es.select { |e| e["ips"].positive? && e["ips"] <= SUSPECT_IPS }
      pick = usable.empty? ? es : usable
      [median(pick.map { |e| e["ips"] }).round(3), median(pick.map { |e| e["error"].to_f }).round(1), ref_ips[i].empty? ? nil : 1.0]
    end
    { entries: entries, passes: passes.map { |r| r["pass"] }.sort }
  end

  # How much the reference varied over its passes: standard deviation / mean per report, the median over the reports; nil with fewer than two passes.
  def variation(ref_ips)
    cvs = ref_ips.select { |v| v.size > 1 }.map do |v|
      mean = v.sum / v.size
      Math.sqrt(v.sum { |x| (x - mean)**2 } / (v.size - 1)) / mean
    end
    cvs.empty? ? nil : median(cvs)
  end

  def median(values)
    s = values.sort
    s.size.odd? ? s[s.size / 2] : (s[s.size / 2 - 1] + s[s.size / 2]) / 2.0
  end

  def cross_meta(reports, labels, reference, benchmarks)
    first = reports.first
    moved = benchmarks.filter_map { |b| b[:variation] }
    typical = moved.empty? ? nil : median(moved)
    shards = reports.group_by { |r| r["shard"] }.sort_by { |k, _| k.to_i }.map do |shard, rs|
      times = rs.map { |r| r["measured_at"] }.sort
      { shard: shard, cpu: rs.first.dig("environment", "cpu"), nproc: rs.first.dig("environment", "nproc"), from: times.first, to: times.last }
    end
    {
      commit: first["commit"],
      run_id: first["run_id"],
      shards_total: first["shards"],
      built_at: Time.now.utc.strftime("%Y-%m-%d %H:%M UTC"),
      repo: REPO_URL,
      labels: labels,
      reference: reference,
      gate: GATE,
      variation: typical&.round(4),
      passed: !typical.nil? && typical <= GATE,
      suspect: SUSPECT_IPS,
      shards: shards,
      descriptions: reports.group_by { |r| r["label"] }.transform_values { |rs| rs.first["ruby_description"] }
    }
  end

  # Per build: the verdict, and ips/error per report in the order of `names`
  # (nil where that report did not run).
  # A 0 i/s result (a broken run) counts as not run: a ratio against it would be infinite, which JSON cannot hold.
  def run_data(report, names)
    entries = report["entries"].select { |e| e["ips"].positive? }
    v = verdict(entries, names.first)
    by_name = entries.to_h { |e| [e["name"], e] }
    v[:ratio] = v[:ratio].round(4) if v[:ratio]
    v[:winner] = names.index(v[:winner]) if v[:winner]
    v.merge(entries: names.map { |n| (e = by_name[n]) && [e["ips"].round(3), e["error"].to_f.round(1)] })
  end

  def meta(reports, labels)
    first = reports.first
    by_label = reports.group_by { |r| r["label"] }.transform_values(&:first)
    {
      commit: first["commit"],
      run_id: first["run_id"],
      built_at: Time.now.utc.strftime("%Y-%m-%d %H:%M UTC"),
      repo: REPO_URL,
      labels: labels,
      default: default_label(labels),
      descriptions: by_label.transform_values { |r| r["ruby_description"] }
    }
  end

  # The newest released MRI: head builds and JIT variants are left out.
  def default_label(labels)
    labels.select { |l| l.match?(/\Aruby_\d[\d.]*\z/) }.max_by { |l| Gem::Version.new(l.delete_prefix("ruby_")) } || labels.first
  end

  # ruby, then jruby, then truffleruby; oldest to newest, head last; the plain
  # build before its JIT variants.
  def label_sort_key(label)
    base, variant = label.split("+", 2)
    engine, version = base.match(/\A([a-z]+)_(.+)\z/)&.captures || [base, ""]
    head = version == "head" ? 1 : 0
    [ENGINES.index(engine) || ENGINES.size, head, version.scan(/\d+/).map(&:to_i), variant.to_s]
  end

  # The title is the report labels, claimed report first: "`String#tr` vs `String#gsub`".
  # A label with a backtick in it is left as plain text, so it cannot break the code style.
  def title_for(names)
    names.map { |n| n.include?("`") ? n : "`#{n}`" }.join(" vs ")
  end

  # code/proc-and-block/proc-call-vs-yield.rb is in "Proc & Block".
  def section_for(file)
    folder = file.split("/")[1].to_s
    SECTIONS.fetch(folder) { folder.split("-").map(&:capitalize).join(" ") }
  end

  # The data goes inline so the page also works opened from disk.
  # "</" is escaped so a report name can never close the script tag.
  def render(does_it_hold, across_rubies = nil)
    File.read(TEMPLATE)
        .sub("/*DOES_IT_HOLD_DATA*/") { "window.DOES_IT_HOLD = #{inline(does_it_hold)};" }
        .sub("/*ACROSS_RUBIES_DATA*/") { "window.ACROSS_RUBIES = #{inline(across_rubies)};" }
  end

  def inline(data)
    JSON.generate(data).gsub("</", "<\\/").gsub("\u2028", "\\u2028").gsub("\u2029", "\\u2029")
  end
end

ResultsSite.build(ARGV[0] || "results", ARGV[1] || "_site") if $PROGRAM_NAME == __FILE__
