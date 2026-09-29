require 'benchmark/ips'
require 'bigdecimal'
require 'bigdecimal/util'

# On Ruby 4.0, building from the Integer is about 2x faster than from a String.
def faster
  BigDecimal(1)
end

def fast
  1.to_d
end

# BigDecimal('1') and '1'.to_d parse the String the same way, so these two should tie.
def slow
  BigDecimal('1')
end

def slower
  '1'.to_d
end

Benchmark.ips do |x|
  x.report('integer new')         { faster }
  x.report('integer to_d')        { fast }
  x.report('integer string new')  { slow }
  x.report('integer string to_d') { slower }
  x.compare!
end
