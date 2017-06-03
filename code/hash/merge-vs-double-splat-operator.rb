require 'benchmark/ips'

def fast
  h2 = { a: 'a' }
  { one: 1, **h2 }
end

def slow
  h2 = { a: 'a' }
  { one: 1 }.merge(h2)
end

Benchmark.ips do |x|
  x.report('Hash#**other') { fast }
  x.report('Hash#merge') { slow }
  x.compare!
end
