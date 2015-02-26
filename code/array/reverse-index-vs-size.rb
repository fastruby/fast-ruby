require 'benchmark/ips'

ARRAY = [*1..1000]

def slow
  ARRAY.reverse.index(60)
end

def fast
  ARRAY.size - ARRAY.index(60) - 1
end

Benchmark.ips do |x|
  x.report('reverse + index') { slow }
  x.report('size - index - 1')  { fast }
  x.compare!
end
