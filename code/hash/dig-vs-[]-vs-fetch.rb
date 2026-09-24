require "benchmark/ips"

HASH = { a: { b: { c: { d: { e: "foo" } } } } }

# Plain Hash#[] is the fastest, but raises NoMethodError when a level is missing.
# Hash#dig returns nil instead, which is why it is the readable choice for nested hashes, at a small cost.
def fastest
  HASH[:a][:b][:c][:d][:e]
end

def faster
  ((((HASH[:a] || {})[:b] || {})[:c] || {})[:d] || {})[:e]
end

def fast
  HASH.dig(:a, :b, :c, :d, :e)
end

def slow
  HASH.fetch(:a).fetch(:b).fetch(:c).fetch(:d).fetch(:e)
end

# These last two swap places across Rubies; this one is faster on 3.2 and newer.
def slower
  HASH[:a] && HASH[:a][:b] && HASH[:a][:b][:c] && HASH[:a][:b][:c][:d] && HASH[:a][:b][:c][:d][:e]
end

def slowest
  HASH.fetch(:a, {}).fetch(:b, {}).fetch(:c, {}).fetch(:d, {}).fetch(:e, nil)
end

Benchmark.ips do |x|
  x.report("Hash#[]") { fastest }
  x.report("Hash#[] ||") { faster }
  x.report("Hash#dig") { fast } if RUBY_VERSION >= "2.3.0"
  x.report("Hash#fetch") { slow }
  x.report("Hash#[] &&") { slower }
  x.report("Hash#fetch fallback") { slowest }
  x.compare!
end
