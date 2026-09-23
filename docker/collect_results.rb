# Loaded with `ruby -r` (through RUBYOPT) when RESULTS_DIR is set. Every
# Benchmark.ips call in a benchmark file also writes its report as JSON to
# RESULTS_DIR/<label>/<benchmark>.json, so the benchmark files stay untouched.
# Each result also records where it ran, so only comparable numbers get
# compared.
#
# Keep this file compatible with the oldest Ruby in the CI matrix (2.1).
#
# JRuby 9.1 can load this file before bundler/setup from RUBYOPT, so set up
# the bundle here to find benchmark-ips either way.
require "bundler/setup"
require "benchmark/ips"
require "fileutils"
require "json"
require "rbconfig"

module CollectResults
  @calls = 0

  class << self
    attr_accessor :calls

    def label
      env("RESULTS_LABEL") || ["#{RUBY_ENGINE}-#{engine_version}", env("RUBY_VARIANT")].compact.join("+")
    end

    def engine_version
      defined?(RUBY_ENGINE_VERSION) ? RUBY_ENGINE_VERSION : RUBY_VERSION
    end

    def write(report)
      self.calls += 1
      benchmark = $0.sub(%r{\A\./}, "")
      name = benchmark.sub(%r{\Acode/}, "").sub(/\.rb\z/, "").gsub("/", "--")
      name += "--#{calls}" if calls > 1

      path = File.join(ENV["RESULTS_DIR"], label, "#{name}.json")
      FileUtils.mkdir_p(File.dirname(path))
      File.write(path, JSON.pretty_generate({
        "benchmark" => benchmark,
        "part" => calls,
        "label" => label,
        "ruby_description" => RUBY_DESCRIPTION,
        "engine" => RUBY_ENGINE,
        "engine_version" => engine_version,
        "ruby_version" => RUBY_VERSION,
        "variant" => env("RUBY_VARIANT"),
        "flags" => env("RUBY_VARIANT_FLAGS"),
        "jit" => jit,
        "commit" => env("RESULTS_COMMIT"),
        "pr" => env("RESULTS_PR") && env("RESULTS_PR").to_i,
        "run_id" => env("GITHUB_RUN_ID"),
        "run_attempt" => env("GITHUB_RUN_ATTEMPT"),
        "runner" => env("RUNNER_NAME"),
        "environment" => environment,
        "entries" => report.data
      }))
    end

    # An empty value counts as unset: CI passes an empty matrix field (no
    # variant) as an empty string.
    def env(name)
      value = ENV[name]
      value unless value.nil? || value.empty?
    end

    def jit
      if defined?(RubyVM::YJIT) && RubyVM::YJIT.enabled?
        "yjit"
      elsif defined?(RubyVM::ZJIT) && RubyVM::ZJIT.respond_to?(:enabled?) && RubyVM::ZJIT.enabled?
        "zjit"
      end
    end

    # The same for every benchmark in a run, so work it out once. A field that
    # cannot be read (no /etc/os-release or ldd outside Docker) is nil; the
    # others are kept.
    def environment
      @environment ||= {
        "arch" => RbConfig::CONFIG["host_cpu"],
        "cpu" => safely { cpu },
        "nproc" => safely { nproc },
        "os" => safely { File.read("/etc/os-release")[/^PRETTY_NAME="?([^"\n]+)/, 1] },
        "glibc" => safely { `ldd --version 2>&1`[/\d+\.\d+/] },
        "cc" => cc_version,
        "optflags" => RbConfig::CONFIG["optflags"],
        "configure_args" => RbConfig::CONFIG["configure_args"]
      }
    end

    def safely
      yield
    rescue SystemCallError
      nil
    end

    # x86 lists a model name. arm64 only lists implementer and part codes,
    # which name the CPU design on servers; inside Docker Desktop's VM on a
    # Mac they only say "Apple", so different Macs look the same.
    def cpu
      model = cpuinfo[/^model name\s*:\s*(.+)$/, 1]
      return model if model

      implementer = cpuinfo[/^CPU implementer\s*:\s*(\S+)/, 1]
      part = cpuinfo[/^CPU part\s*:\s*(\S+)/, 1]
      "CPU implementer #{implementer}, part #{part}" if implementer && part
    end

    def cpuinfo
      File.exist?("/proc/cpuinfo") ? File.read("/proc/cpuinfo") : ""
    end

    # Etc.nprocessors is Ruby 2.2+.
    def nproc
      require "etc"
      Etc.respond_to?(:nprocessors) ? Etc.nprocessors : cpuinfo.scan(/^processor\s*:/).size
    end

    # CC_VERSION_MESSAGE is only set by newer CRubies; nil elsewhere.
    def cc_version
      message = RbConfig::CONFIG["CC_VERSION_MESSAGE"]
      message && message.lines.first.strip
    end
  end

  def ips(*args, &block)
    report = super
    CollectResults.write(report) if report.respond_to?(:data)
    report
  end
end

# Benchmark extends Benchmark::IPS, so the hook goes on Benchmark's singleton
# class. Prepending to Benchmark::IPS would not reach it before Ruby 3.0.
Benchmark.singleton_class.send(:prepend, CollectResults)
