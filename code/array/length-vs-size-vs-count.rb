require 'benchmark/ips'

ARRAY = [*1..100]

def fast
  ARRAY.length
end

def slow
  ARRAY.size
end

def slower
  ARRAY.count
end

Benchmark.ips(quiet: true) do |x|
  x.report("Array#length") { fast }
  x.report("Array#size  ") { slow }
  x.report("Array#count ") { slower }
  x.compare!
end
