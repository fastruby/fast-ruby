require "benchmark/ips"
require "set"

# Check whether ARRAY1 is a subset of ARRAY2 (every element of ARRAY1 is in
# ARRAY2). The fastest approach is highly dependent on the input: `all?` +
# `include?` short-circuits on the first miss (great for non-subsets) but is
# O(n*m) when ARRAY1 really is a subset, while Set-based lookups stay O(n).
ARRAY1 = [*1..25]
ARRAY2 = [*1..100]

def minus_empty
  (ARRAY1 - ARRAY2).empty?
end

def intersection_equal
  (ARRAY1 & ARRAY2) == ARRAY1
end

def intersection_size
  (ARRAY1 & ARRAY2).size == ARRAY1.size
end

def all_include
  ARRAY1.all? { |element| ARRAY2.include?(element) }
end

def set_subset
  ARRAY1.to_set.subset?(ARRAY2.to_set)
end

# Sanity check: every approach must return the same answer.
results = [minus_empty, intersection_equal, intersection_size, all_include, set_subset]
raise "not equivalent: #{results.inspect}" unless results.uniq.size == 1

Benchmark.ips do |x|
  x.report("(a1 - a2).empty?")     { minus_empty }
  x.report("(a1 & a2) == a1")      { intersection_equal }
  x.report("(a1 & a2).size == n")  { intersection_size }
  x.report("a1.all? { include? }") { all_include }
  x.report("a1.to_set.subset?")    { set_subset }
  x.compare!
end
