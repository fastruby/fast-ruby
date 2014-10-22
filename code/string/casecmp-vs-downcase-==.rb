require 'benchmark/ips'

SLUG = 'ABCD'

def slow
  SLUG.downcase == 'abcd'
end

def fast
  SLUG.casecmp('abcd') == 0
end

Benchmark.ips do |x|
  x.report('slow') { slow }
  x.report('fast') { fast }
  x.compare!
end
