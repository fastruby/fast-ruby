require "benchmark/ips"

h = { a: { b: { c: { d: { e: "foo" } } } } }

def fastest
  h[:a][:b][:c][:d][:e]
end

def faster
  h.dig(:a, :b, :c, :d, :e)
end

def fast
  ((((h[:a] || {})[:b] || {})[:c] || {})[:d] || {})[:e]
end

def slow
  h.fetch(:a).fetch(:b).fetch(:c).fetch(:d).fetch(:e)
end

def slower
  h.fetch(:a, {}).fetch(:b, {}).fetch(:c, {}).fetch(:d, {}).fetch(:e, nil)
end

def slowest
  h[:a] && h[:a][:b] && h[:a][:b][:c] && h[:a][:b][:c][:d] && h[:a][:b][:c][:d][:e]
end

Benchmark.ips(quiet: true) do |x|
  x.report "Hash#[]            " { fastest }
  x.report "Hash#dig           " { faster  }
  x.report "Hash#[] ||         " { fast    }
  x.report "Hash#fetch         " { slow    }
  x.report "Hash#fetch fallback" { slower  }
  x.report "Hash#[] &&         " { slowest }
  x.compare!
end
