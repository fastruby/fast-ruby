require "benchmark/ips"
require "ostruct"

def fast
  { field_1: 1, field_2: 2 }
end

def slow
  OpenStruct.new(field_1: 1, field_2: 2)
end

Benchmark.ips do |x|
  x.report("Hash")       { fast }
  x.report("OpenStruct") { slow }
  x.compare!
end
