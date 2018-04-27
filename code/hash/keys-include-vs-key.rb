require "benchmark/ips"

HASH = Hash[*("a".."zzz").to_a.shuffle]

def key_present_fast
  HASH.key? "z"
end

def key_present_slow
  HASH.keys.include? "z"
end

def key_absent_fast
  HASH.key? 3
end

def key_absent_slow
  HASH.keys.include? 3
end

def value_present_fast
  HASH.value? "z"
end

def value_present_slow
  HASH.values.include? "z"
end

def value_absent_fast
  HASH.value? 3
end

def value_absent_slow
  HASH.values.include? 3
end

Benchmark.ips do |x|
  x.report("Hash#key? (key is present)") { key_present_fast }
  x.report("Hash#keys.include? (key is present)") { key_present_slow }
  x.compare!
end

Benchmark.ips do |x|
  x.report("Hash#key? (key is absent)") { key_absent_fast }
  x.report("Hash#keys.include? (key is absent)") { key_absent_slow }
  x.compare!
end

Benchmark.ips do |x|
  x.report("Hash#value? (value is present)") { value_present_fast }
  x.report("Hash#values.include? (value is present)") { value_present_slow }
  x.compare!
end

Benchmark.ips do |x|
  x.report("Hash#value? (value is absent)") { value_absent_fast }
  x.report("Hash#values.include? (value is absent)") { value_absent_slow }
  x.compare!
end
