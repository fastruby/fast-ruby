require 'benchmark/ips'

SLUG = 'ABCD'

def fast
  SLUG.casecmp('abcd') == 0
end

def slow
  SLUG.downcase == 'abcd'
end

def slower
  SLUG.casecmp?('abcd')
end

Benchmark.ips do |x|
  x.report('String#casecmp')       { fast }
  x.report('String#downcase + ==') { slow }
  x.report("String#casecmp?")      { slower } if RUBY_VERSION >= "2.4.0".freeze
  x.compare!
end
