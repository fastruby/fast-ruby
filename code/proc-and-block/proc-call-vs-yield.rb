require 'benchmark/ips'

def fast
  yield
end

def slow(&block)
  yield
end

def slower(&block)
  block.call
end

Benchmark.ips do |x|
  x.report('yield')         { fast { 1 + 1 } }
  x.report('block + yield') { slow { 1 + 1 } }
  x.report('block.call')    { slower { 1 + 1 } }
  x.compare!
end
