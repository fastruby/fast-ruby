require "benchmark/ips"
require 'active_support'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/try'

class A
  def foo
    self
  end
end

def fast
  a = A.new
  a &.foo &.foo
end

def slow
  a = A.new
  a && a.foo && a.foo.foo
end

def slower
  a = A.new
  a.present? && a.foo.present? && a.foo.foo
end

def slowest
  a = A.new
  a.try(:foo).try(:foo)
end

Benchmark.ips do |x|
  x.report("safe navigation operator")  { fast }
  x.report("explicit check") { slow }
  x.report("#present?") { slower }
  x.report("#try") { slowest }
  x.compare!
end
