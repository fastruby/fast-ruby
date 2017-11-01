require 'benchmark/ips'

def slow
  'string'.to_sym
end

def fast
  :'string'
end

Benchmark.ips do |x|
  x.report('String#to_sym') { slow }
  x.report(':string')     { fast }
  x.compare!
end
