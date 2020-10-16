require "benchmark/ips"

HASH = Hash[*("a".."zzz").to_a.shuffle]
VALUE = "zz"

def value_fast
  HASH.value? VALUE
end

def value_slow
  HASH.values.include? VALUE
end

Benchmark.ips do |x|
  x.report("Hash#values.include?") { value_slow }
  x.report("Hash#value?") { value_fast }
  x.compare!
end
