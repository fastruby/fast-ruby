require 'benchmark/ips'

def fast
  a, b, c, d, e, f, g, h = 1, 2, 3, 4, 5, 6, 7, 8
  nil
end

def slow
  a = 1
  b = 2
  c = 3
  d = 4
  e = 5
  f = 6
  g = 7
  h = 8
  nil
end

Benchmark.ips do |x|
  x.report('Parallel Assignment')   { fast }
  x.report('Sequential Assignment') { slow }
  x.compare!
end
