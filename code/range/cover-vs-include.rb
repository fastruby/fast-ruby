require "benchmark/ips"
require "date"

BEGIN_OF_JULY = Date.new(2015, 7, 1)
END_OF_JULY = Date.new(2015, 7, 31)
DAY_IN_JULY = Date.new(2015, 7, 15)

def fast
  (BEGIN_OF_JULY..END_OF_JULY).cover? DAY_IN_JULY
end

def slow
  (BEGIN_OF_JULY..END_OF_JULY).include? DAY_IN_JULY
end

Benchmark.ips do |x|
  x.report("Range#cover?") { fast }
  x.report("Range#include?") { slow }
  x.compare!
end
