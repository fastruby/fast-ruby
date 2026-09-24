require "benchmark/ips"

HASH = Hash[*("a".."zzz").to_a] # 9139 pairs, same order every run
KEY = HASH.keys[HASH.size / 2] # always found halfway through

def fast
  HASH.key? KEY
end

def slow
  HASH.keys.include? KEY
end

Benchmark.ips do |x|
  x.report("Hash#key?") { fast }
  x.report("Hash#keys.include?") { slow }
  x.compare!
end
