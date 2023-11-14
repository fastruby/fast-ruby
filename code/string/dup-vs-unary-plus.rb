# frozen_string_literal: true

require 'benchmark/ips'

if RUBY_VERSION >= '2.3.0'
  def fast
    +''
  end

  def slow
    ''.dup
  end

  Benchmark.ips do |x|
    x.report('String#+@') { fast }
    x.report('String#dup') { slow }
    x.compare!
  end
end
