require "rubygems"
require "benchmark/ips"

ARRAY = (1..1000).to_a

def fast
  ARRAY.sum
end

def slow
  ARRAY.inject(:+)
end

Benchmark.ips do |x|
  x.report('sum')                { fast }
  x.report('inject symbol plus') { slow }

  x.compare!
end
