# Runs every build on this one machine, one after the other, so their i/s can be compared (the "Across Rubies" view of the results site):
#
#   ruby script/run_cross_ruby.rb [--shard 0 --shards 6] [options]
#
# The reference build (the latest stable MRI) runs first, again after every few builds, and last.
# It is the same code every time, so its passes show how steady the machine was during the run.
# Each pass writes its results to <out>/pass-NN/<label>/, and the run order goes to <out>/order-<shard>.json (one per shard, so merged artifacts keep them all).
# CI runs it from .github/workflows/results-site.yml.
require "fileutils"
require "json"
require "optparse"
require "yaml"
require_relative "build_results_site"

module CrossRuby
  # The builds come from the CI matrix, so a Ruby added there (a service in compose.yaml and a matrix entry) is measured here too.
  # The newest released MRI among them becomes the reference, the same rule that picks the site's default Ruby.
  MATRIX = File.expand_path("../.github/workflows/benchmarks.yml", __dir__)

  module_function

  # Every build of the rake job's matrix, as [compose service, variant, flags]: the plain Rubies, then the include entries (the JIT builds).
  def builds(workflow = MATRIX)
    matrix = YAML.safe_load(File.read(workflow), aliases: true).dig("jobs", "rake", "strategy", "matrix")
    abort "No rake matrix in #{workflow}" unless matrix && matrix["ruby"]

    plain = matrix["ruby"].map { |s| [s, nil, nil] }
    variants = (matrix["include"] || []).map { |i| [i["ruby"], i["variant"], i["flags"]] }
    (plain + variants).freeze
  end

  def label(build)
    [build[0], build[1]].compact.join("+")
  end

  # Every shards-th file of the sorted list, so each shard gets a mix of sections.
  def shard_files(files, shard, shards)
    files.sort.each_with_index.select { |_, i| i % shards == shard }.map(&:first)
  end

  # The reference first, after every `every` builds, and last.
  # The other builds are shuffled with the seed (so a run can be repeated) by Ruby: a Ruby's interpreter and JIT builds run back to back, so each image is fetched once and the JIT is compared with the interpreter minutes apart.
  def passes(builds, reference, every, seed)
    random = Random.new(seed)
    groups = builds.reject { |b| b == reference }.group_by(&:first).values
    others = groups.shuffle(random: random).flat_map { |g| g.shuffle(random: random) }
    [reference] + others.each_slice(every).flat_map { |slice| slice + [reference] }
  end

  def capture(cmd)
    IO.popen(cmd, &:read)
  end

  def run(argv)
    opts = { shard: 0, shards: 1, every: 3, out: "results", seed: (ENV["GITHUB_RUN_ID"] || rand(1 << 31)).to_i }
    OptionParser.new do |o|
      o.on("--shard N", Integer, "Which shard to run, from 0 (default 0)") { |v| opts[:shard] = v }
      o.on("--shards N", Integer, "How many shards the files are split into (default 1)") { |v| opts[:shards] = v }
      o.on("--every N", Integer, "Run the reference again after every N builds (default 3)") { |v| opts[:every] = v }
      o.on("--seed N", Integer, "Seed for the build order (default: the CI run id, or random)") { |v| opts[:seed] = v }
      o.on("--out DIR", "Where results go (default results)") { |v| opts[:out] = v }
      o.on("--files A,B", Array, "Only these benchmark files") { |v| opts[:files] = v }
      o.on("--builds A,B", Array, "Only these builds, by label (ruby_3.4, ruby_3.4+yjit)") { |v| opts[:builds] = v }
      o.on("--project NAME", "docker compose project name (-p)") { |v| opts[:project] = v }
      o.on("--fresh-images", "Pull or build each image first and remove it after (CI: keeps the disk free)") { opts[:fresh] = true }
      o.on("--dry-run", "Print the commands instead of running them") { opts[:dry] = true }
    end.parse!(argv)
    abort "--shard must be between 0 and #{opts[:shards] - 1}" unless (0...opts[:shards]).cover?(opts[:shard])
    # Paths below (code/, --files, --out) are from the repo root.
    # The benchmarks write their results from inside a container that only sees the repo (mounted at /app), so --out has to be inside it.
    root = File.expand_path("..", __dir__)
    out = File.expand_path(opts[:out], root)
    abort "--out must be a folder inside #{root}: the benchmarks write their results from a container that only sees the repo" unless out.start_with?(root + File::SEPARATOR)
    opts[:out] = out.delete_prefix(root + File::SEPARATOR)
    Dir.chdir(root)

    all = builds
    builds = all
    if opts[:builds]
      unknown = opts[:builds] - all.map { |b| label(b) }
      abort "Unknown builds: #{unknown.join(", ")}" unless unknown.empty?
      builds = all.select { |b| opts[:builds].include?(label(b)) }
    end
    # The same rule as the site's default Ruby: the newest released MRI.
    ref_label = ResultsSite.default_label(builds.map { |b| label(b) })
    reference = builds.find { |b| label(b) == ref_label }
    abort "No MRI build to use as the reference" unless reference && reference[0].start_with?("ruby_") && !reference[1]

    files = shard_files(opts[:files] || Dir["code/*/*.rb"], opts[:shard], opts[:shards])
    abort "No benchmark files in shard #{opts[:shard]}" if files.empty?
    order = passes(builds, reference, opts[:every], opts[:seed])

    puts "Shard #{opts[:shard]} of #{opts[:shards]}: #{files.size} files, #{order.size} passes, reference #{ref_label}, seed #{opts[:seed]}"
    puts "Order: #{order.map { |b| label(b) }.join(" ")}"
    FileUtils.mkdir_p(opts[:out])
    compose = ["docker", "compose"] + (opts[:project] ? ["-p", opts[:project]] : [])
    # Services built from docker/Dockerfile (the head builds, TruffleRuby 22); the rest are pulled.
    built = JSON.parse(capture(compose + ["config", "--format", "json"]))["services"].select { |_, svc| svc["build"] }.keys
    # With --fresh-images: an image is fetched before its service's first pass
    # and removed after its last one; the reference's image stays to the end.
    last_pass = order.each_with_index.to_h { |b, i| [b[0], i] }
    ready = {}
    log = { seed: opts[:seed], shard: opts[:shard], shards: opts[:shards], every: opts[:every], reference: ref_label, files: files, passes: [] }
    failed = []

    order.each_with_index do |build, pass|
      service, variant, flags = build
      name = label(build)
      ref = build.equal?(reference)
      puts "", "== Pass #{pass + 1} of #{order.size}: #{name}#{" (reference)" if ref}"
      if opts[:fresh] && !ready.key?(service)
        prepare = built.include?(service) ? "build" : "pull"
        ready[service] = sh(compose + [prepare, service], opts)
      end
      if ready[service] == false
        failed << "#{name} (image #{built.include?(service) ? "build" : "pull"} failed)"
        next
      end

      env = {
        "RESULTS_DIR" => File.join(opts[:out], format("pass-%02d", pass + 1)),
        "RESULTS_LABEL" => name,
        "RESULTS_PASS" => (pass + 1).to_s,
        "RESULTS_REFERENCE" => ref ? "1" : "",
        "RESULTS_SHARD" => opts[:shard].to_s,
        "RESULTS_SHARDS" => opts[:shards].to_s,
        "RUBY_VARIANT" => variant.to_s,
        "RUBY_VARIANT_FLAGS" => flags.to_s
      }
      started = Time.now.utc
      ok = sh(compose + ["run", "--rm", "-T", service] + files, opts, env)
      failed << name unless ok
      log[:passes] << { pass: pass + 1, label: name, reference: ref, started_at: started.strftime("%FT%TZ"), finished_at: Time.now.utc.strftime("%FT%TZ"), ok: ok }

      if opts[:fresh] && last_pass[service] == pass && service != reference[0]
        images = capture(compose + ["config", "--images", service]).split
        sh(["docker", "image", "rm", "-f"] + images, opts) unless images.empty?
      end
    end

    File.write(File.join(opts[:out], "order-#{opts[:shard]}.json"), JSON.pretty_generate(log)) unless opts[:dry]
    return if failed.empty?

    warn "", "Failed passes (their other results were kept):", *failed
    exit 1
  end

  def sh(cmd, opts, env = {})
    if opts[:dry]
      puts((env.reject { |_, v| v.empty? }.map { |k, v| "#{k}=#{v}" } + cmd).join(" "))
      return true
    end
    system(env, *cmd)
  end
end

CrossRuby.run(ARGV) if $PROGRAM_NAME == __FILE__
