require "benchmark/ips"

# Build a hash where roughly half the values are nil, so every approach
# below returns the same result: the non-nil values.
ARRAY = Array.new(1000) { Random.rand }
HASH = Hash[ARRAY.map { |k| [k, k < 0.5 ? k : nil] }]

def select_values
  HASH.select { |_k, v| v }.values
end

def values_select
  HASH.values.select { |v| v }
end

def values_compact
  HASH.values.compact
end

# Sanity check: all three must return the same values.
raise "not equivalent" unless select_values.sort == values_select.sort &&
                              values_select.sort == values_compact.sort

Benchmark.ips do |x|
  x.report("Hash#select.values") { select_values }
  x.report("Hash#values.select") { values_select }
  x.report("Hash#values.compact") { values_compact }
  x.compare!
end
