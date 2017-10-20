require "benchmark/ips"

HASH = { writing: :fast_ruby }
DEFAULT = "fast ruby"

def fast
  HASH.fetch(:writing, DEFAULT)
end

def slow
  HASH.fetch(:writing) { "fast ruby" }
end

def slower
  HASH.fetch(:writing, "fast ruby")
end

Benchmark.ips(quiet: true) do |x|
  x.report("Hash#fetch + const") { fast }
  x.report("Hash#fetch + block") { slow }
  x.report("Hash#fetch + arg  ") { slower }
  x.compare!
end
