require 'benchmark/ips'

data = [ nil ]

Benchmark.ips do |x|
  x.report('array.concat(array)')   { data.concat(data) }
  x.report('array + array')         { data + data     }
  x.compare!
end
