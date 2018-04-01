require "benchmark/ips"

def fast
  "foo".freeze.match?(/boo/)
end

def slow
  "foo".freeze =~ /boo/
end

def slower
  /boo/ === "foo".freeze  
end

def slowest
  "foo".freeze.match(/boo/)
end

Benchmark.ips do |x|
  x.report("String#match?") { fast } if RUBY_VERSION >= "2.4.0".freeze
  x.report("String#=~") { slow }
  x.report("Regexp#===") { slower }
  x.report("String#match") { slowest }
  x.compare!
end
