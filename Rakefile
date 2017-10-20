desc "run benchmark in current ruby"
task :run_benchmark do
  system("ruby", "-v")
  puts "\n"

  Dir["code/general/*.rb"].each do |benchmark|
    puts "$ ruby #{benchmark}"
    system("ruby", "-W0", benchmark)
  end

  Dir["code/*/*.rb"].reject { |path| path =~ /^code\/general/ }.each do |benchmark|
    puts "$ ruby #{benchmark}"
    system("ruby", "-W0", benchmark)
  end
end

task default: :run_benchmark
