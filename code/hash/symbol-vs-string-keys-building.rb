require 'benchmark/ips'

# The same 1000 keys, as Symbols, frozen Strings and plain Strings, each mapped to its index.
SYMBOL_KEYS = (1..1000).map { |i| :"key_#{i}" }
FROZEN_KEYS = (1..1000).map { |i| "key_#{i}".freeze }
STRING_KEYS = (1..1000).map { |i| "key_#{i}" }

def build(keys)
  keys.each_with_index.map { |key, index| [key, index] }.to_h
end

# Symbol and frozen String keys tie on Ruby 4.0.
def faster
  build(SYMBOL_KEYS)
end

# A Hash copies and freezes a plain String key, but keeps a frozen one as it is.
def fast
  build(FROZEN_KEYS)
end

def slow
  build(STRING_KEYS)
end

Benchmark.ips do |x|
  x.report('Symbol Keys') { faster }
  x.report('Frozen Keys') { fast }
  x.report('String Keys') { slow }
  x.compare!
end
