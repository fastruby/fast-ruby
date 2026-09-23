desc "run benchmark in current ruby"
task :run_benchmark do
  failed = []

  Dir["code/general/*.rb"].each do |benchmark|
    puts "$ ruby -v #{benchmark}"
    failed << benchmark unless system("ruby", "-v", "-W0", benchmark)
  end

  Dir["code/*/*.rb"].reject { |path| path =~ /^code\/general/ }.each do |benchmark|
    puts "$ ruby -v #{benchmark}"
    failed << benchmark unless system("ruby", "-v", "-W0", benchmark)
  end

  unless failed.empty?
    abort "Failed benchmarks:\n#{failed.join("\n")}\n\n" \
          "If a benchmark needs a newer Ruby, make it skip older ones, see " \
          "\"Benchmarks that need a newer Ruby\" in CONTRIBUTING.md."
  end
end

task default: :run_benchmark
