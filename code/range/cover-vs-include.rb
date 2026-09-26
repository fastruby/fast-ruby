require "benchmark/ips"
require "date"

BEGIN_OF_JULY = Date.new(2015, 7, 1)
END_OF_JULY = Date.new(2015, 7, 31)
DAY_IN_JULY = Date.new(2015, 7, 15)

# between? and plain compare only compare the dates, without building a Range, so they beat range#cover?.
def fastest
  DAY_IN_JULY.between?(BEGIN_OF_JULY, END_OF_JULY)
end

def faster
  BEGIN_OF_JULY < DAY_IN_JULY && DAY_IN_JULY < END_OF_JULY
end

# cover? only compares with the ends of the range; include? and member? walk it, since Date is not numeric.
def fast
  (BEGIN_OF_JULY..END_OF_JULY).cover? DAY_IN_JULY
end

def slow
  (BEGIN_OF_JULY..END_OF_JULY).include? DAY_IN_JULY
end

# Range#member? is an alias of Range#include?, so these two should tie.
def slower
  (BEGIN_OF_JULY..END_OF_JULY).member? DAY_IN_JULY
end

Benchmark.ips do |x|
  x.report('value.between?') { fastest }
  x.report('plain compare') { faster }
  x.report('range#cover?') { fast }
  x.report('range#include?') { slow }
  x.report('range#member?') { slower }
  x.compare!
end
