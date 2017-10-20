require 'benchmark/ips'

SLUG = 'ABCD'

def fast
  SLUG.casecmp('abcd') == 0
end

def slow
  SLUG.downcase == 'abcd'
end

Benchmark.ips(quiet: true) do |x|
  x.report('String#casecmp      ') { fast }
  x.report('String#downcase + ==') { slow }
  x.compare!
end
