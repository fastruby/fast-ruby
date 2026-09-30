require 'benchmark/ips'

# The same 1000 keys, as Symbols, frozen Strings and plain Strings, each mapped to its index.
SYMBOL_KEYS = (1..1000).map { |i| :"key_#{i}" }
FROZEN_KEYS = (1..1000).map { |i| "key_#{i}".freeze }
STRING_KEYS = (1..1000).map { |i| "key_#{i}" }

SYMBOL_HASH = SYMBOL_KEYS.each_with_index.map { |key, index| [key, index] }.to_h
FROZEN_HASH = FROZEN_KEYS.each_with_index.map { |key, index| [key, index] }.to_h
STRING_HASH = STRING_KEYS.each_with_index.map { |key, index| [key, index] }.to_h

# Reads every key once.
def faster
  SYMBOL_KEYS.each { |key| SYMBOL_HASH[key] }
end

def fast
  FROZEN_KEYS.each { |key| FROZEN_HASH[key] }
end

def slow
  STRING_KEYS.each { |key| STRING_HASH[key] }
end

Benchmark.ips do |x|
  x.report('Symbol Keys') { faster }
  x.report('Frozen Keys') { fast }
  x.report('String Keys') { slow }
  x.compare!
end
