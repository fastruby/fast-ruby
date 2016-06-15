require "benchmark/ips"
require 'active'
NUMBER = 100_000_000

class A
  def foo
  end
end

def fast
  a = A.new
  a&.foo
end

def slow
  a = A.new
  a && a.foo
end

Benchmark.ips do |x|
  x.report("&.")  { fast }
  x.report("&&") { slow }
  x.compare!
end
