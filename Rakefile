desc "run benchmark in current ruby"
task :run_benchmark do
  if ENV['CI'] == '1'
    system('mkdir', '-p', 'reports')
    output_to_report = ">> reports/#{RUBY_VERSION}.txt"
  end

  Dir["code/*/*.rb"].sort_by { |path| path =~ /^code\/general/ ? 0 : 1 }.each do |benchmark|
    command = "ruby -v -W0 #{benchmark}"

    if ENV['CI'] == '1'
      system("echo '$ ruby -v #{benchmark}' #{output_to_report}")
      command += " #{output_to_report}"
    else
      puts "$ ruby -v #{benchmark}"
    end

    system(command)
  end
end

task default: :run_benchmark
