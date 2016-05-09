require 'benchmark/ips'

HASH = { a: 1, b: 2, c: 3, d: 4, e: 5, f: 6, g: 7, h: 8, i: 9, j: 10, k: 11, l: 12, m: 13, n: 14 }

def slow
  HASH.each { |(key, val)| key; val }
end

def fast
  HASH.each_key { |key| key; HASH[key] }
end

def fastest
  HASH.each { |key, val| key; val }
end

Benchmark.ips do |x|
  x.report('Enum#each') { slow }
  x.report('Hash#each(each_pair)')  { fastest }
  x.report('Hash#each_key')  { fast }
  x.compare!
end
