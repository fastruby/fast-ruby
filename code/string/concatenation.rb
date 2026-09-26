require 'benchmark/ips'

# Object counts are per call, measured on Ruby 3.4.

# 1 object: the result.
# Both of these are built from literals when the file is parsed, so they are close; which one wins varies by Ruby version.
def faster
  "#{'foo'}#{'bar'}"
end

# 1 object: the result.
def fast
  'foo' 'bar'
end

# 2 objects: 'foo' and 'bar'; 'foo' is changed in place.
def slow
  'foo' << 'bar'
end

# 2 objects: 'foo' and 'bar'; 'foo' is changed in place.
def slower
  'foo'.concat 'bar'
end

# 3 objects: 'foo', 'bar' and the new result.
def slowest
  'foo' + 'bar'
end

Benchmark.ips do |x|
  x.report('"#{\'foo\'}#{\'bar\'}"')   { faster }
  x.report('"foo" "bar"')              { fast }
  x.report('String#append')            { slow }
  x.report('String#concat')            { slower }
  x.report('String#+')                 { slowest }
  x.compare!
end
