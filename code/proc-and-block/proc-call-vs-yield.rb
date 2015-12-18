require 'benchmark/ips'

def slow(&block)
  block.call
end

def slow2(&block)
  yield
end

def slow3(&block)

end

def fast
  yield
end

Benchmark.ips do |x|
  x.report('block.call') { slow { 1 + 1 } }
  x.report('block + yield') { slow2 { 1 + 1 } }
  x.report('block argument') { slow3 { 1 + 1 } }
  x.report('yield')      { fast { 1 + 1 } }
  x.compare!
end
