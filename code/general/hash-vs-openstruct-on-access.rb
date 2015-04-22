require "benchmark/ips"
require "ostruct"

 HASH = { field_1: 1, field_2: 2}
 OPENSTRUCT = OpenStruct.new(field_1: 1, field_2: 2)

def fast
  [HASH[:field_1], HASH[:field_2]]
end

def slow
  [OPENSTRUCT.field_1, OPENSTRUCT.field_2]
end

Benchmark.ips do |x|
  x.report("Hash")       { fast }
  x.report("OpenStruct") { slow }
  x.compare!
end
