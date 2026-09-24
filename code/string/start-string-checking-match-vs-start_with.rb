require 'benchmark/ips'

SLUG = 'test_some_kind_of_long_file_name.rb'

# String#match? wins on Ruby 3.4 (with or without YJIT).
# start_with? wins on the other Rubies CI runs.
def fast
  SLUG.start_with?('test_')
end

def slow
  SLUG.match?(/^test_/)
end

def slower
  SLUG =~ /^test_/
end

Benchmark.ips do |x|
  x.report('String#start_with?') { fast }
  x.report('String#match?')      { slow } if RUBY_VERSION >= "2.4.0".freeze
  x.report('String#=~')          { slower }
  x.compare!
end
