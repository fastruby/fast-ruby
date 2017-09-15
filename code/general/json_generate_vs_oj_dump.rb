require 'benchmark/ips'
require 'oj'
require 'json'

HASH = Hash[*('a'..'z').to_a]

def fast
  Oj.dump(HASH)
end

def slow
  JSON.generate(HASH)
end

Benchmark.ips do |x|
  x.report("Oj::dump") { fast }
  x.report("JSON::generate") { slow }
  x.compare!
end
