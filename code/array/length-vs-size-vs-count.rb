require 'benchmark/ips'

ARRAY = [*1..100]

def fastest
  ARRAY.length
end

# Array#size is an alias of Array#length, so these two should tie.
def faster
  ARRAY.size
end

def slow
  ARRAY.count
end

Benchmark.ips do |x|
  x.report("Array#length") { fastest }
  x.report("Array#size") { faster }
  x.report("Array#count") { slow }
  x.compare!
end
