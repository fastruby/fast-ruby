require 'benchmark/ips'

ARRAY = [*1..7777]

def fast
  ARRAY.reverse.detect { |x| (x % 5).zero? }
end

def slow
  ARRAY.select { |x| (x % 5).zero? }.last
end

Benchmark.ips do |x|
  x.report('Enumerable#reverse.detect') { fast }
  x.report('Enumerable#select.last')    { slow }
  x.compare!
end
