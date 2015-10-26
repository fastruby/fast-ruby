require 'benchmark/ips'

def slow &block
  block
end

def slow2
  Proc.new
end


Benchmark.ips do |x|
  x.report("&block") { slow { 1 + 1 } }
  x.report("Proc.new") { slow2 { 1 + 1 } }
  x.compare!
end
