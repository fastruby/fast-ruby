require 'benchmark/memory'

EM_HASH = {}.freeze

def test_hash(a={}); end
def test_hash2(a=EM_HASH); end

def fast
  10_000.times{ test_hash2 }
end

def slow
  10_000.times{ test_hash }
end

Benchmark.memory do |x|
  x.report('constant as default argument  ') { fast }
  x.report('new object as default argument') { slow }
  x.compare!
end