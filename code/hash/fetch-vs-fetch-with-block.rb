require "benchmark/ips"

HASH = { writing: :fast_ruby }
DEFAULT = "fast ruby"

# The default is written differently on purpose:
# a string argument is built on every call, even when the key exists.
# The block builds it only when the key is missing,
# and the constant is built once, so those two are close.
def fastest
  HASH.fetch(:writing, DEFAULT)
end

def faster
  HASH.fetch(:writing) { "fast ruby" }
end

def slow
  HASH.fetch(:writing, "fast ruby")
end

Benchmark.ips do |x|
  x.report("Hash#fetch + const") { fastest }
  x.report("Hash#fetch + block") { faster }
  x.report("Hash#fetch + arg")   { slow }
  x.compare!
end
