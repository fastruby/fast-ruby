require 'benchmark/ips'

ARRAY = [*1..100]

def slow
  ARRAY.each_with_index do |number, index|
    number + index
  end
end

def fast
  index = 0
  while index < ARRAY.size
    ARRAY[index] + index
    index += 1
  end
  ARRAY
end

Benchmark.ips do |x|
  x.report('each_with_index') { slow  }
  x.report('While Loop')      { fast  }
  x.compare!
end
