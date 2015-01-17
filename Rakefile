desc "run benchmark in current ruby"
task :run_benchmark do
  Dir["code/general/*.rb"].each do |benchmark|
    puts "$ ruby -v #{benchmark}"
    system("ruby", "-v", benchmark)
  end

  Dir["code/*/*.rb"].reject { |path| path =~ /^code\/general/ }.each do |benchmark|
    puts "$ ruby -v #{benchmark}"
    system("ruby", "-v", benchmark)
  end
end

task default: :run_benchmark
