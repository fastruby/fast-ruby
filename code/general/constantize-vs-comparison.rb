require "active_support/core_ext/string/inflections.rb"
require "benchmark/ips"

class Foo; end

def fast(s)
  klass = Foo if s == "Foo"
  nil
end

def slow(s)
  klass = s.constantize
  nil
end

Benchmark.ips do |x|
  x.report("using an if statement") { fast("Foo") }
  x.report("String#constantize") { slow("Foo") }
  x.compare!
end
