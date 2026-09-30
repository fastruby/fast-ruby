# Builds the results site from the JSON written by docker/collect_results.rb:
#
#   ruby script/build_results_site.rb [results_dir] [output_dir]
#
# results_dir defaults to results/ and output_dir to _site/. Result files are
# found at any depth, so both a local results/<label>/ folder and CI's merged
# artifacts work. The site answers one question per benchmark: does the
# report the file claims is fastest win on this Ruby and build? Every verdict
# compares reports inside one run, never one Ruby or build against another:
# each build ran as its own CI job, often on a different CPU model.
require "fileutils"
require "json"

module ResultsSite
  REPO_URL = "https://github.com/fastruby/fast-ruby".freeze
  ENGINES = %w[ruby jruby truffleruby].freeze
  TEMPLATE = File.expand_path("results_site.html", __dir__)

  # Over a billion iterations per second is under 1 ns per iteration: the JIT
  # most likely removed the work (TruffleRuby reports hundreds of billions).
  SUSPECT_IPS = 1e9

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
    # Only result files: anything else under results_dir
    # (a site built there earlier, another artifact) has no "entries".
    reports = Dir[File.join(results_dir, "**", "*.json")].sort.map { |path| JSON.parse(File.read(path)) }
    reports.select! { |r| r.is_a?(Hash) && r["entries"].is_a?(Array) && r["label"] }
    abort "No results found in #{results_dir}" if reports.empty?

    data = site_data(reports)
    FileUtils.rm_rf(output_dir)
    FileUtils.mkdir_p(output_dir)
    File.write(File.join(output_dir, "index.html"), render(data))
    File.write(File.join(output_dir, "results.json"), JSON.generate(data))
    puts "Built #{data[:benchmarks].size} benchmarks on #{data[:meta][:labels].size} builds into #{output_dir}"
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

  def site_data(reports)
    labels = reports.map { |r| r["label"] }.uniq.sort_by { |l| label_sort_key(l) }
    grouped = reports.group_by { |r| [r["benchmark"], r["part"]] }
    multi_part = grouped.keys.group_by(&:first).select { |_, parts| parts.size > 1 }.keys

    benchmarks = grouped.map do |(file, part), runs|
      # The run with the most reports has them all; older Rubies can skip a
      # report guarded by RUBY_VERSION.
      names = runs.max_by { |r| r["entries"].size }["entries"].map { |e| e["name"] }
      title = title_for(names)
      title += " (part #{part})" if multi_part.include?(file)
      {
        file: file,
        part: part,
        title: title,
        section: section_for(file),
        names: names,
        runs: runs.to_h { |r| [r["label"], run_data(r, names)] }
      }
    end

    order = SECTIONS.values
    benchmarks.sort_by! { |b| [order.index(b[:section]) || order.size, b[:section], b[:file], b[:part]] }
    # Two files with the same report labels get their file name added.
    benchmarks.group_by { |b| b[:title] }.each_value do |same|
      same.each { |b| b[:title] += " (#{File.basename(b[:file])})" } if same.size > 1
    end

    { meta: meta(reports, labels), benchmarks: benchmarks }
  end

  # Per build: the verdict, and ips/error per report in the order of `names`
  # (nil where that report did not run).
  def run_data(report, names)
    entries = report["entries"]
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
      pr: first["pr"],
      # Set by CI when a benchmark job failed: its results are missing, which looks like a skip.
      incomplete: ENV["RESULTS_INCOMPLETE"] == "1",
      built_at: Time.now.utc.strftime("%Y-%m-%d %H:%M UTC"),
      repo: REPO_URL,
      labels: labels,
      default: default_label(labels),
      descriptions: by_label.transform_values { |r| r["ruby_description"] },
      cpus: by_label.transform_values { |r| r.dig("environment", "cpu") }
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

  # The data goes inline so the page also works opened from disk. "</" is
  # escaped so a report name can never close the script tag.
  def render(data)
    json = JSON.generate(data).gsub("</", "<\\/").gsub("\u2028", "\\u2028").gsub("\u2029", "\\u2029")
    File.read(TEMPLATE).sub("/*RESULTS_DATA*/") { "window.RESULTS = #{json};" }
  end
end

ResultsSite.build(ARGV[0] || "results", ARGV[1] || "_site") if $PROGRAM_NAME == __FILE__
