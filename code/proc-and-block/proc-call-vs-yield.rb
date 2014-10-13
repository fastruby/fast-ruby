require 'benchmark/ips'

def slow &block
  block.call
end

def fast
  yield
end

Benchmark.ips do |x|
  x.report('block.call') { slow { 1 + 1 } }
  x.report('yield')      { fast { 1 + 1 } }
  x.compare!
end
