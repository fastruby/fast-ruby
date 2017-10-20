require 'benchmark/ips'

SLUG = 'test_reverse_merge.rb'

def fast
  SLUG.start_with?('test_')
end

def slow
  SLUG =~ /^test_/
end

Benchmark.ips(quiet: true) do |x|
  x.report('String#start_with?') { fast }
  x.report('String#=~         ') { slow }
  x.compare!
end
