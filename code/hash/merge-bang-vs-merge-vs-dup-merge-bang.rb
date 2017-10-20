require "benchmark/ips"

ENUM = (1..100)
ORIGINAL_HASH = { foo: "foo" }

def fast
  ENUM.inject([]) do |accumulator, element|
    accumulator << ({ bar: element }.merge!(ORIGINAL_HASH){ |_key, left, _right| left })
  end
end

def slow
  ENUM.inject([]) do |accumulator, element|
    accumulator << ORIGINAL_HASH.dup.merge!(bar: element)
  end
end

def slower
  ENUM.inject([]) do |accumulator, element|
    accumulator << ORIGINAL_HASH.merge(bar: element)
  end
end

Benchmark.ips(quiet: true) do |x|
  x.report("{}#merge!(Hash) do end") { fast }
  x.report("Hash#dup#merge!({})   ") { slow }
  x.report("Hash#merge({})        ") { slower }
  x.compare!
end
