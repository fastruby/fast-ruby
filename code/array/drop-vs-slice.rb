require 'benchmark/ips'

ARRAY = (1..100).to_a

def fast
  ARRAY.drop(1)
end

def slow
  ARRAY[1..]
end

Benchmark.ips do |x|
  x.report('Array#drop') { fast }
  x.report('Array#[]')   { slow }
  x.compare!
end
