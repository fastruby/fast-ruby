require 'benchmark/ips'

ARRAY = [*1..100]

def faster
  ARRAY.length
end

# Array#size is an alias of Array#length, so these two should tie.
def fast
  ARRAY.size
end

def slow
  ARRAY.count
end

Benchmark.ips do |x|
  x.report("Array#length") { faster }
  x.report("Array#size") { fast }
  x.report("Array#count") { slow }
  x.compare!
end
