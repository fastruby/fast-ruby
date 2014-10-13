require 'benchmark/ips'

RANGE = (1..100)

def slow
  RANGE.map { |i| i.to_s }
end

def fast
  RANGE.map(&:to_s)
end

Benchmark.ips do |x|
  x.report('Block')          { slow }
  x.report('Symbol#to_proc') { fast }
  x.compare!
end
