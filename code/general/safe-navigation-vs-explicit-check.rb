require "benchmark/ips"
require 'active_support'
require 'active_support/core_ext/object/try'


def fast
  o = Object.new
  o &.itself &.itself
end

def slow
  o = Object.new
  o && o.itself && o.itself.itself
end

def slowest
  o = Object.new
  o.try(:itself).try(:itself)
end

Benchmark.ips do |x|
  x.report('safe navigation operator')  { fast }
  x.report('explicit presence check') { slow }
  x.report('#try!') { slowest }
  x.compare!
end
