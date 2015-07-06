require "benchmark/ips"

HASH_WITH_SYMBOL = { fast: "ruby" }
HASH_WITH_STRING = { "fast" => "ruby" }

def fastest
  HASH_WITH_SYMBOL[:fast]
end

def faster
  HASH_WITH_SYMBOL.fetch(:fast)
end

def fast
  HASH_WITH_STRING["fast"]
end

def slow
  HASH_WITH_STRING.fetch("fast")
end

Benchmark.ips do |x|
  x.report("Hash#[], symbol")    { fastest }
  x.report("Hash#fetch, symbol") { faster  }
  x.report("Hash#[], string")    { fast    }
  x.report("Hash#fetch, string") { slow    }
  x.compare!
end
