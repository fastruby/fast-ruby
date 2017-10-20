require 'benchmark/ips'

ARRAY = (1..100).to_a

def fast
  ARRAY.flat_map { |e| [e, e] }
end

def slow
  ARRAY.map { |e| [e, e] }.flatten(1)
end

def slower
  ARRAY.map { |e| [e, e] }.flatten
end

Benchmark.ips(quiet: true) do |x|
  x.report('Array#flat_map      ') { fast   }
  x.report('Array#map.flatten(1)') { slow   }
  x.report('Array#map.flatten   ') { slower }
  x.compare!
end
