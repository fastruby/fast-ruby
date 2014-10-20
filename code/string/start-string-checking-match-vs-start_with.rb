require 'benchmark/ips'

SLUG = 'test_reverse_merge.rb'

def slow
  SLUG =~ /^test_/
end

def fast
  SLUG.start_with?('test_')
end

Benchmark.ips do |x|
  x.report('String#=~')          { slow }
  x.report('String#start_with?') { fast }
  x.compare!
end
