require 'benchmark/ips'

ARRAY = [*1..100]

def slow
  ARRAY.shuffle.first
end

def fast
  ARRAY.sample
end

Benchmark.ips do |x|
  x.report('Array#sample')        { fast }
  x.report('Array#shuffle.first') { slow }
  x.compare!
end
