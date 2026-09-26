require "benchmark/ips"

# Regexp#match? and String#match? tie on almost every Ruby; either one could come first.
def fastest
  /boo/.match?('foo'.freeze)
end

def faster
  "foo".freeze.match?(/boo/)
end

def fast
  "foo".freeze =~ /boo/
end

def slow
  /boo/ === "foo".freeze
end

def slower
  /boo/.match('foo'.freeze)
end

def slowest
  "foo".freeze.match(/boo/)
end

Benchmark.ips do |x|
  x.report("Regexp#match?") { fastest } if RUBY_VERSION >= "2.4.0".freeze
  x.report("String#match?") { faster } if RUBY_VERSION >= "2.4.0".freeze
  x.report("String#=~") { fast }
  x.report("Regexp#===") { slow }
  x.report("Regexp#match") { slower }
  x.report("String#match") { slowest }
  x.compare!
end
