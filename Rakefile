desc "run benchmark in current ruby"
task :run_benchmark do
  ENV['SHARE'] = ENV['GITHUB_ACTIONS'] # only share to http://ips.fastruby.io when running within GitHub Actions env

  Dir["code/general/*.rb"].each do |benchmark|
    puts "$ ruby -v #{benchmark}"
    system("ruby", "-v", "-W0", benchmark)
  end

  Dir["code/*/*.rb"].reject { |path| path =~ /^code\/general/ }.each do |benchmark|
    puts "$ ruby -v #{benchmark}"
    system("ruby", "-v", "-W0", benchmark)
  end
end

task default: :run_benchmark
