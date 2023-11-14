require 'benchmark/ips'

SLUG = 'test_some_kind_of_long_file_name.rb'

def slower
  SLUG =~ /^test_/
end

def slow
  SLUG.match?(/^test_/)
end

def fast
  SLUG.start_with?('test_')
end

Benchmark.ips do |x|
  x.report('String#=~')          { slower }
  x.report('String#match?')      { slow } if RUBY_VERSION >= "2.4.0".freeze
  x.report('String#start_with?') { fast }
  x.compare!
end
