require "active_support/core_ext/string/inflections.rb"
require "benchmark/ips"

class Foo; end

def fast3(s, h)
  klass = h[s]
  nil
end

def fast2(s)
  klass = case s
  when "Foo"
    Foo
  end
  nil
end

def fast(s)
  klass = Foo if s == "Foo"
  nil
end

def slow(s)
  klass = s.constantize
  nil
end

Benchmark.ips do |x|
  h = { "Foo" => Foo }

  x.report("using a Hash") { fast3("Foo", h) }
  x.report("using a case statement") { fast2("Foo") }
  x.report("using an if statement") { fast("Foo") }
  x.report("String#constantize") { slow("Foo") }
  x.compare!
end
