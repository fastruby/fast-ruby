require "benchmark/ips"

ENUM = (1..100)
ORIGINAL_HASH = { foo: "foo" }

def fast
  ENUM.inject([]) do |accumulator, element|
    accumulator << { bar: element }.merge!(ORIGINAL_HASH)
  end
end

def slow
  ENUM.inject([]) do |accumulator, element|
    accumulator << ORIGINAL_HASH.merge(bar: element)
  end
end

def slow_dup
  ENUM.inject([]) do |accumulator, element|
    accumulator << ORIGINAL_HASH.dup.merge!(bar: element)
  end
end

Benchmark.ips do |x|
  x.report("{}#merge!(Hash)") { fast }
  x.report("Hash#merge({})") { slow }
  x.report("Hash#dup#merge!({})") { slow_dup }
  x.compare!
end
