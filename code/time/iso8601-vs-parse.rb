require 'benchmark/ips'
require 'time'

STRING = '2018-03-21T11:26:50Z'.freeze

def fast
  Time.iso8601(STRING)
end

def slow
  Time.parse(STRING)
end

Benchmark.ips do |x|
  x.report('Time.iso8601') { fast }
  x.report('Time.parse') { slow }
  x.compare!
end
