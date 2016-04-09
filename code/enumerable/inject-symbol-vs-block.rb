require "rubygems"
require "benchmark/ips"

ARRAY = (1..1000).to_a

def fastest
  ARRAY.inject(:+)
end

def fast
  ARRAY.inject(&:+)
end

def slow
  ARRAY.inject { |a, i| a + i }
end

Benchmark.ips do |x|
  x.report('inject symbol') { fastest }
  x.report('inject to_proc') { fast }
  x.report('inject block')   { slow }

  x.compare!
end
