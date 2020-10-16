require 'benchmark/ips'

SLUG = 'YourSubclassType'

def slow
  SLUG.sub(/Type\z/, '')
end

def fast
  SLUG.chomp('Type')
end

def faster
  SLUG.delete_suffix('Type')
end

Benchmark.ips do |x|
  x.report('String#sub') { slow }
  x.report("String#chomp") { fast }
  x.report("String#delete_suffix") { faster } if RUBY_VERSION >= '2.5.0'
  x.compare!
end
