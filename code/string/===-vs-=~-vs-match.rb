require "benchmark/ips"

def fastest
  "foo".freeze.include? 'boo'
end

def faster
  "foo".freeze =~ /boo/
end

def fast
  /boo/ === "foo".freeze  
end

def slow
  "foo".freeze.match(/boo/)
end

Benchmark.ips do |x|
  x.report("String#include?") { fastest }
  x.report("String#=~") { faster }
  x.report("Regexp#===") { fast }
  x.report("String#match") { slow }
  x.compare!
end
