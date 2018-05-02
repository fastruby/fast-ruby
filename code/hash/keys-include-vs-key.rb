require "benchmark/ips"

HASH = Hash[*("a".."zzz").to_a.shuffle]
KEY = "zz"

def key_fast
  HASH.key? KEY
end

def key_slow
  HASH.keys.include? KEY
end

Benchmark.ips do |x|
  x.report("Hash#keys.include?") { key_slow }
  x.report("Hash#key?") { key_fast }
  x.compare!
end
