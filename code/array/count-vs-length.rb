require 'benchmark/ips'

ARRAY = [*1..100]

Benchmark.ips do |x|
  x.report('#length') { ARRAY.length }
  x.report('#count') { ARRAY.count }
  x.compare!
end
