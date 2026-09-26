require 'benchmark/ips'

NUMBERS = [*0..100_000_000]

def fast
  NUMBERS.bsearch { |number| number > 77_777_777 }
end

def slow
  NUMBERS.find { |number| number > 77_777_777 }
end

Benchmark.ips do |x|
  x.report('bsearch') { fast }
  x.report('find')    { slow }
  x.compare!
end
