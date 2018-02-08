require "rubygems"
require "benchmark/ips"

ARRAY = (1..1000).to_a

def fastest
  ARRAY.inject(:+)
end

def fast
  a = 0
  ARRAY.each { |i| a += i }
  a
end

def slow
  ARRAY.inject(&:+)
end

def slowest
  ARRAY.inject { |a, i| a + i }
end

Benchmark.ips do |x|
  x.report('inject symbol')             { fastest }
  x.report('each block without inject') { fast }
  x.report('inject to_proc')            { slow }
  x.report('inject block')              { slowest }

  x.compare!
end
