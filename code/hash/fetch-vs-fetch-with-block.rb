require 'benchmark/ips'

HASH = { :writing => :fast_ruby }

def slow
  HASH.fetch(:writing, [*1..100])
end

def fast
  HASH.fetch(:writing) { [*1..100] }
end

Benchmark.ips do |x|
  x.report('Hash#fetch + arg')   { slow }
  x.report('Hash#fetch + block') { fast }
  x.compare!
end
