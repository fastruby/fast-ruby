require 'benchmark/ips'

ARRAY = (1..100).to_a

def slow
  ARRAY.index(ARRAY.find { |i| i % 5 == 0 && i % 7 == 0 })
end

def fast
  ARRAY.find_index { |i| i % 5 == 0 && i % 7 == 0 }
end

Benchmark.ips do |x|
  x.report('Enumerable#index + #find')    { slow }
  x.report('Enumerable#find_index')       { fast }
  x.compare!
end
