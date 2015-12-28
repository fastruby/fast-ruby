require 'benchmark/ips'

SLUG = 'YourSubclassType'

def slow
  SLUG.sub(/Type\z/, '')
end

def fast
  SLUG.chomp('Type')
end

Benchmark.ips do |x|
  x.report('String#sub/regexp/')   { slow }
  x.report("String#chomp'string'") { fast }
  x.compare!
end
