require 'benchmark/ips'

ARRAY = [*1..100]

def slow
  ARRAY.count
end

def fast
  ARRAY.size
end

Benchmark.ips do |x|
  x.report('#count') { slow }
  x.report('#size')  { fast }
  x.compare!
end
