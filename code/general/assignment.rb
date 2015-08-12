require 'benchmark/ips'

def fast
  _a, _b, _c, _d, _e, _f, _g, _h = 1, 2, 3, 4, 5, 6, 7, 8
  nil
end

def slow
  _a = 1
  _b = 2
  _c = 3
  _d = 4
  _e = 5
  _f = 6
  _g = 7
  _h = 8
  nil
end

Benchmark.ips do |x|
  x.report('Parallel Assignment')   { fast }
  x.report('Sequential Assignment') { slow }
  x.compare!
end
