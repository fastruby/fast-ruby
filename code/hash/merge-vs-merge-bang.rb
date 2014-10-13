require 'benchmark/ips'

ENUM = (1..100)

def slow
  ENUM.inject({}) do |h, e|
    h.merge(e => e)
  end
end

def fast
  ENUM.inject({}) do |h, e|
    h.merge!(e => e)
  end
end

Benchmark.ips do |x|
  x.report('Hash#merge') { slow }
  x.report('Hash#merge!') { fast }
  x.compare!
end
