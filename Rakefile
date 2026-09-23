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

  abort "Failed benchmarks:\n#{failed.join("\n")}" unless failed.empty?
end

task default: :run_benchmark
