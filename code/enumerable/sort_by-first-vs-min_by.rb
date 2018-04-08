require 'benchmark/ips'

ARRAY = [*1..100]

def fast
  ARRAY.min_by { |x| x.succ }
end

def slow
  ARRAY.sort_by { |x| x.succ }.first
end

Benchmark.ips do |x|
  x.report('Enumerable#min_by') { fast }
  x.report('Enumerable#sort_by...first') { slow }
  x.compare!
end
