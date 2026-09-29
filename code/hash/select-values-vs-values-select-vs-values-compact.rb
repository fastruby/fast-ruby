require 'benchmark/ips'

# A hash where every other value is nil, the same on every run, so every approach below returns the same result: the 500 non-nil values.
HASH = Hash[(1..1000).map { |k| [k, k.even? ? k : nil] }]

def fast
  HASH.values.compact
end

def slow
  HASH.values.select { |v| !v.nil? }
end

def slower
  HASH.select { |_k, v| !v.nil? }.values
end

# Sanity check: all three must return the same values, in the same order.
raise 'not equivalent' unless [fast, slow, slower].uniq.size == 1

Benchmark.ips do |x|
  x.report('Hash#values.compact') { fast }
  x.report('Hash#values.select')  { slow }
  x.report('Hash#select.values')  { slower }
  x.compare!
end
