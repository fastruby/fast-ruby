require 'benchmark/ips'

data = [*0..100_000_000].shuffle

Benchmark.ips do |x|
  x.report('find')    { data.find    { |number| number > 77_777_777 } }
  x.report('bsearch') { data.bsearch { |number| number > 77_777_777 } }
  x.compare!
end
