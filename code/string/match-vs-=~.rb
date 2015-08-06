require 'benchmark/ips'

def fast
  "foo".freeze =~ /boo/
end

def slow
  "foo".freeze.match(/boo/)
end

Benchmark.ips do |x|
  x.report("String#=~") { fast }
  x.report("String#match") { slow }
  x.compare!
end
