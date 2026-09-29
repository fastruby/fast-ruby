require 'benchmark/ips'

ARRAY = [*1..100]

# Reads ARRAY.size once, before the loop, instead of on every iteration.
def faster
  index = 0
  size = ARRAY.size
  while index < size
    ARRAY[index] + index
    index += 1
  end
  ARRAY
end

def fast
  index = 0
  while index < ARRAY.size
    ARRAY[index] + index
    index += 1
  end
  ARRAY
end

def slow
  ARRAY.each_with_index do |number, index|
    number + index
  end
end

Benchmark.ips do |x|
  x.report('While cached size') { faster }
  x.report('While Loop')        { fast }
  x.report('each_with_index')   { slow }
  x.compare!
end
