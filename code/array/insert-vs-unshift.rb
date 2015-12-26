require 'benchmark/ips'

Benchmark.ips do |x|
  x.report('Array#unshift') do
    array = []
    100_000.times { |i| array.unshift(i) }
  end

  x.report('Array#insert') do
    array = []
    100_000.times { |i| array.insert(0, i) }
  end

  x.compare!
end
