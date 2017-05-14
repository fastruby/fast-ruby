require 'benchmark/ips'

ARRAY1 = [*1..25]
ARRAY2 = [*1..100]

def slow_minus_empty
  (ARRAY1 - ARRAY2).empty?
end

def slow_interception
  (ARRAY1 & ARRAY2) == ARRAY1
end

def fast
  ARRAY1.all?{|element| ARRAY2.include?(element) }
end

Benchmark.ips do |x|
  x.report("(a1 - a2).empty?") { slow_minus_empty }
  x.report("(a1 & a2) == a1 ") { slow_interception }
  x.report("Array#all?#include?") { fast }
  x.compare!
end
