require 'benchmark/ips'

ARRAY = [*1..100]

def fast
    ARRAY[-1]
end

def slow
    ARRAY.last
end

Benchmark.ips do |x|
      x.report('fast code description') { fast }
      x.report('slow code description') { slow }
      x.compare!
end
