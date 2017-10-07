require "benchmark/ips"


STRING_KEYS = (1..1000).map{|x| "key_#{x}"}.shuffle
SYMBOL_KEYS = STRING_KEYS.map(&:to_sym)

def symbol_hash
  SYMBOL_KEYS.collect { |k| [ k, rand(1..100)]}.to_h
end

def string_hash
  STRING_KEYS.collect { |k| [ k, rand(1..100)]}.to_h
end


Benchmark.ips do |x|

  x.report("Symbol Keys") { symbol_hash }
  x.report("String Keys") { string_hash }

  x.compare!
end
