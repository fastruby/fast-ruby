require "benchmark/ips"
require 'active_support'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/object/try'

def fastest
  o = Object.new
  o.itself.itself
end

def fast
  o = Object.new
  o &.itself &.itself
end

def slow
  o = Object.new
  o && o.itself && o.itself.itself
end

def slower
  o = Object.new
  o.present? && o.itself.present? && o.itself.itself
end

def slowest
  o = Object.new
  o.try(:itself).try(:itself)
end

Benchmark.ips do |x|
  x.report('method calling')  { fastest }
  x.report('safe navigation operator')  { fast }
  x.report('explicit presence check') { slow }
  x.report('#present?') { slower }
  x.report('#try') { slowest }
  x.compare!
end
