require 'benchmark/ips'

ARRAY = [*1..100]

def fast
  ARRAY[-1]
end

def slow
  ARRAY.last
end

Benchmark.ips do |x|
  x.report('Array#[-1]') { fast }
  x.report('Array#last') { slow }
  x.compare!
end
