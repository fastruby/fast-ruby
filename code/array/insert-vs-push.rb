require 'benchmark/ips'

def fast
  array = []
  100_000.times { |i| array.push(i) }
end

def slower
  array = []
  100_000.times { |i| array.insert(-1, i) }
end

def slowest
  array = []
  100_000.times { |i| array.insert(array.count - 1, i) }
end

Benchmark.ips do |x|
  x.report('Array#push') { fast }
  x.report('Array#insest with -1') { slower }
  x.report('Array#insest with last index') { slowest }

  x.compare!
end
