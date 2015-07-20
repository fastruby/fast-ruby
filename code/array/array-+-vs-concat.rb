require 'benchmark/ips'

def fast
  [1, 2, 3] + [4, 5, 6]
end

def slow
  [1, 2, 3].concat [4, 5, 6]
end

Benchmark.ips do |x|
  x.report("Array#+") { fast }
  x.report("Array#concat") { slow }
  x.compare!
end
