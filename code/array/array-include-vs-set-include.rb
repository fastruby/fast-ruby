require 'benchmark/ips'
require 'set'

ARRAY = (1..100).to_a
SET = (1..100).to_a.to_set
SORTED_SET = SortedSet.new (1..100).to_a

def fast
  SET.include?(rand(101))
end

def slow
  ARRAY.include?(rand(101))
end

def also_fast
  SORTED_SET.include?(rand(101))
end

Benchmark.ips do |x|
  x.report('Set#include?') { fast }
  x.report('SortedSet#include?') { also_fast }
  x.report('Array#include?') { slow }
  x.compare!
end
