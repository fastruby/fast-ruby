require 'benchmark/ips'
require 'bigdecimal'
require 'bigdecimal/util'

# On Ruby 4.0, building from the Float is about 1.3x faster than from a String.
# The precision argument (2) is there for older Rubies, where BigDecimal(1.0) raises "can't omit precision for a Float".
def faster
  BigDecimal(1.0, 2)
end

def fast
  1.0.to_d
end

# BigDecimal('1.0') and '1.0'.to_d parse the String the same way, so these two should tie.
def slow
  BigDecimal('1.0')
end

def slower
  '1.0'.to_d
end

Benchmark.ips do |x|
  x.report('float new')         { faster }
  x.report('float to_d')        { fast }
  x.report('float string new')  { slow }
  x.report('float string to_d') { slower }
  x.compare!
end
