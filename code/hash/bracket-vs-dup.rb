require 'benchmark/ips'

HASH = Hash[*('a'..'z').to_a]

def fast
  Hash[HASH]
end

def slow
  HASH.dup
end

Benchmark.ips do |x|
  x.report("Hash[]")   { fast }
  x.report("Hash#dup") { slow }
  x.compare!
end
