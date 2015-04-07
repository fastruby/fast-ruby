require "benchmark/ips"

HASH = Hash[*("a".."z").to_a.shuffle]

def fast
  HASH.sort_by { |k, _v| k }.to_h
end

def slow
  HASH.sort.to_h
end

Benchmark.ips do |x|
  x.report("sort_by + to_h") { fast }
  x.report("sort + to_h")    { slow }
  x.compare!
end
