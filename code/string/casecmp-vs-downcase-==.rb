require 'benchmark/ips'

SLUG = 'ABCD'

def slow
  SLUG.downcase == 'abcd'
end

def fast
  SLUG.casecmp('abcd') == 0
end

Benchmark.ips do |x|
  x.report('String#downcase + ==') { slow }
  x.report('String#casecmp')       { fast }
  x.compare!
end
