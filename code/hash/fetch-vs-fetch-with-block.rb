require "benchmark/ips"

HASH = { writing: :fast_ruby }

def fast
  HASH.fetch(:writing) { "fast ruby" }
end

def slow
  HASH.fetch(:writing, "fast ruby")
end

Benchmark.ips do |x|
  x.report("Hash#fetch + block") { fast }
  x.report("Hash#fetch + arg")   { slow }
  x.compare!
end
