require "benchmark/ips"

ARRAY = (1..1000).to_a

def faster
  ARRAY.inject(:+)
end

# Symbol#to_proc beats the block on plain CRuby up to 3.4; the block wins with YJIT or ZJIT, on 4.0 and newer, and on JRuby.
def fast
  ARRAY.inject(&:+)
end

def slow
  ARRAY.inject { |a, i| a + i }
end

Benchmark.ips do |x|
  x.report('inject symbol')  { faster }
  x.report('inject to_proc') { fast }
  x.report('inject block')   { slow }
  x.compare!
end
