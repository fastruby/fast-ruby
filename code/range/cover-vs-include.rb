require "benchmark/ips"
require "date"

BEGIN_OF_JULY = Date.new(2015, 7, 1)
END_OF_JULY = Date.new(2015, 7, 31)
DAY_IN_JULY = Date.new(2015, 7, 15)

def fast
  BEGIN_OF_JULY < DAY_IN_JULY && DAY_IN_JULY < END_OF_JULY
end

def slow
  (BEGIN_OF_JULY..END_OF_JULY).cover? DAY_IN_JULY
end

def slower
  (BEGIN_OF_JULY..END_OF_JULY).include? DAY_IN_JULY
end

def slowest
  (BEGIN_OF_JULY..END_OF_JULY).member? DAY_IN_JULY
end

Benchmark.ips(quiet: true) do |x|
  x.report('plain compare ') { fast    }
  x.report('range#cover?  ') { slow    }
  x.report('range#include?') { slower  }
  x.report('range#member? ') { slowest }
  x.compare!
end
