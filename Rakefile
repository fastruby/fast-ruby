desc 'run benchmark in current ruby'
task :run_benchmark do
  Dir['code/*/*.rb'].each do |benchmark|
    puts "$ ruby -v #{benchmark}"
    system('ruby', '-v', benchmark)
  end
end

task default: :run_benchmark
