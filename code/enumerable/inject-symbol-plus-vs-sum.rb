require 'benchmark/ips'

if RUBY_VERSION >= '2.4.0'
  ARRAY = (1..1000).to_a

  # The two agree for Integers.
  # For Floats, Array#sum compensates for rounding errors: ([0.1] * 10).sum is 1.0, inject(:+) gives 0.9999999999999999.
  def fast
    ARRAY.sum
  end

  def slow
    ARRAY.inject(:+)
  end

  Benchmark.ips do |x|
    x.report('Array#sum')        { fast }
    x.report('Array#inject(:+)') { slow }
    x.compare!
  end
end
