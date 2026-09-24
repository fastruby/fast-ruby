require 'benchmark/ips'

ARRAY = [*1..100]

def slow
  for number in ARRAY do
    number
  end
end

def fast
  ARRAY.each do |number|
    number
  end
end

Benchmark.ips do |x|
  x.report('#each')    { fast  }
  x.report('For loop') { slow  }
  x.compare!
end
