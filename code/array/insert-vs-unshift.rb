require 'benchmark/ips'

def fast
  array = []
  100_000.times { |i| array.unshift(i) }
end

def slow
  array = []
  100_000.times { |i| array.insert(0, i) }
end

Benchmark.ips(quiet: true) do |x|
  x.report('Array#unshift') { fast }
  x.report('Array#insert ') { slow }
  x.compare!
end
