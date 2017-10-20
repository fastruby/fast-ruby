require 'benchmark/ips'

data = [*0..100_000_000]

def fast
  data.bsearch { |number| number > 77_777_777 }
end

def slow
  data.find { |number| number > 77_777_777 }
end

Benchmark.ips(quiet: true) do |x|
  x.report('bsearch') { fast }
  x.report('find   ') { slow }
  x.compare!
end
