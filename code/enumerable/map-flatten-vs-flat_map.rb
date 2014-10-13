require 'benchmark/ips'

ARRAY = (1..100).to_a

def slow_flatten_1
  [1, [[2, [[[3, [[[[4, [[[[[5]]]]]]]]]]]]]]].map(&:to_s).flatten(1)
end

def slow_flatten
  [1, [[2, [[[3, [[[[4, [[[[[5]]]]]]]]]]]]]]].map(&:to_s).flatten
end

def fast
  [1, [[2, [[[3, [[[[4, [[[[[5]]]]]]]]]]]]]]].map(&:to_s).flat_map
end

Benchmark.ips do |x|
  x.report('Array#map.flatten(1)') { slow_flatten_1 }
  x.report('Array#map.flatten')    { slow_flatten   }
  x.report('Array#flat_map')       { fast           }
  x.compare!
end
