require 'benchmark/ips'

ARRAY = [*1..100]

def slow
  ARRAY.select { |x| (x % 10).zero? }.last
end

def fast
  ARRAY.reverse.detect { |x| (x % 10).zero? }
end

Benchmark.ips do |x|
  x.report('Enumerable#select.last') { slow }
  x.report('Enumerable#reverse.detect') { fast }
  x.compare!
end
