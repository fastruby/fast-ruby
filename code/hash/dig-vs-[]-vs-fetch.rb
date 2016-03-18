require 'benchmark/ips'

h = { a: { b: { c: { d: { e: "foo" } } } } }

Benchmark.ips do |x|
  x.report 'Hash#dig' do
    h.dig(:a, :b, :c, :d, :e)
  end

  x.report 'Hash#[]' do
    h[:a][:b][:c][:d][:e]
  end

  x.report 'Hash#[] ||' do
    ((((h[:a] || {})[:b] || {})[:c] || {})[:d] || {})[:e]
  end

  x.report 'Hash#[] &&' do
    h[:a] && h[:a][:b] && h[:a][:b][:c] && h[:a][:b][:c][:d] && h[:a][:b][:c][:d][:e]
  end

  x.report 'Hash#fetch' do
    h.fetch(:a).fetch(:b).fetch(:c).fetch(:d).fetch(:e)
  end

  x.report 'Hash#fetch fallback' do
    h.fetch(:a, {}).fetch(:b, {}).fetch(:c, {}).fetch(:d, {}).fetch(:e, nil)
  end

  x.compare!
end
