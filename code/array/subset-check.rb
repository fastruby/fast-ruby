require 'benchmark/ips'
require 'set'

# Check whether ARRAY1 is a subset of ARRAY2 (every element of ARRAY1 is in ARRAY2).
# The fastest approach depends on the input: `all?` + `include?` stops at the first miss (great for non-subsets) but is O(n*m) when ARRAY1 really is a subset, while Set-based lookups stay O(n).
ARRAY1 = [*1..25]
ARRAY2 = [*1..100]

# On CRuby 3.4 and newer (a1 - a2).empty? wins; on JRuby and TruffleRuby all? + include? does, and on 2.1 the two tie.
def faster
  (ARRAY1 - ARRAY2).empty?
end

def fast
  ARRAY1.all? { |element| ARRAY2.include?(element) }
end

def slow
  (ARRAY1 & ARRAY2).size == ARRAY1.size
end

def slower
  (ARRAY1 & ARRAY2) == ARRAY1
end

def slowest
  ARRAY1.to_set.subset?(ARRAY2.to_set)
end

# Sanity check: every approach must return the same answer.
results = [faster, fast, slow, slower, slowest]
raise "not equivalent: #{results.inspect}" unless results.uniq.size == 1

Benchmark.ips do |x|
  x.report('(a1 - a2).empty?')     { faster }
  x.report('a1.all? { include? }') { fast }
  x.report('(a1 & a2).size == n')  { slow }
  x.report('(a1 & a2) == a1')      { slower }
  x.report('a1.to_set.subset?')    { slowest }
  x.compare!
end
