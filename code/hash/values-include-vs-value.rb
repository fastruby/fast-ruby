require "benchmark/ips"

HASH = Hash[*("a".."zzz").to_a] # 9139 pairs, same order every run
VALUE = HASH.values[HASH.size / 2] # always found halfway through

# Hash#value? scans the hash directly; Hash#values.include? first copies every value into a new array.
# On CRuby the two tie at this position; Hash#value? wins on JRuby and TruffleRuby.
def fast
  HASH.value? VALUE
end

def slow
  HASH.values.include? VALUE
end

Benchmark.ips do |x|
  x.report("Hash#value?") { fast }
  x.report("Hash#values.include?") { slow }
  x.compare!
end
