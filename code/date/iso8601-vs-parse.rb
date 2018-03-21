require 'benchmark/ips'
require 'date'

STRING = '2018-03-21'.freeze

def fast
  Date.iso8601(STRING)
end

def slow
  Date.parse(STRING)
end

Benchmark.ips do |x|
  x.report('Date.iso8601') { fast }
  x.report('Date.parse') { slow }
  x.compare!
end
