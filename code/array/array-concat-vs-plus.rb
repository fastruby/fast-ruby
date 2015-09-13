require 'benchmark/ips'

data = Array.new

Benchmark.ips do |x|
  x.report('array.concat(array)')   { data.concat(data) }
  x.report('array + array')         { data + data     }
  x.compare!
end
