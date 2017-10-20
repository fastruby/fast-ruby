require 'benchmark/ips'

def fast
  yield
end

def slow(&block)
end

def slower(&block)
  yield
end

def slowest(&block)
  block.call
end

Benchmark.ips(quiet: true) do |x|
  x.report('yield         ') { fast { 1 + 1 }    }
  x.report('block argument') { slow { 1 + 1 }    }
  x.report('block + yield ') { slower { 1 + 1 }  }
  x.report('block.call    ') { slowest { 1 + 1 } }
  x.compare!
end
