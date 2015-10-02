require "benchmark/ips"

module M
  ITEMS = (1..10000).to_a.freeze

  def self.func(*args)
  end
end

def fast
  M.func(M::ITEMS)
end

def slow
  M.func(*M::ITEMS)
end

Benchmark.ips do |x|
  x.report("Function with single Array argument") { fast }
  x.report("Function with splat arguments") { slow }
  x.compare!
end
