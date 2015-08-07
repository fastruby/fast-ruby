require 'benchmark/ips'

ARRAY = [*1..100]

Benchmark.ips do |x|
  x.report("Array#length") { ARRAY.length }
  x.report("Array#size") { ARRAY.size }
  x.report("Array#count") { ARRAY.count }
  x.compare!
end
