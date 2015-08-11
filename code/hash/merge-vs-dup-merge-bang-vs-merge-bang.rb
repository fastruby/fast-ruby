require 'benchmark/ips'

ENUM = (1..100)
ORIGINAL_HASH = { key1: 'value 1' }

def slow
  ENUM.inject([]) do |a, e|
    a << ORIGINAL_HASH.merge(key2: e)
  end
end

def slow_dup
  ENUM.inject([]) do |a, e|
    a << ORIGINAL_HASH.dup.merge!(key2: e)
  end
end

def fast
  ENUM.inject([]) do |a, e|
    a << { key2: e }.merge!(ORIGINAL_HASH)
  end
end

Benchmark.ips do |x|
  x.report('Hash#merge({})') { slow }
  x.report('Hash#dup#merge!({})') { slow_dup }
  x.report('{}#merge!(Hash)') { fast }
  x.compare!
end
