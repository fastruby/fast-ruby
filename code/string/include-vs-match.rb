require 'benchmark/ips'

# For a fixed substring, String#include? beats a Regexp with =~.
# String#match? (Ruby 2.4+) is as fast as include? or faster on current CRuby.
def faster
  'foo'.freeze.match?(/boo/)
end

def fast
  'foo'.freeze.include?('boo')
end

def slow
  'foo'.freeze =~ /boo/
end

Benchmark.ips do |x|
  x.report('String#match?')   { faster } if RUBY_VERSION >= '2.4.0'
  x.report('String#include?') { fast }
  x.report('String#=~')       { slow }
  x.compare!
end
