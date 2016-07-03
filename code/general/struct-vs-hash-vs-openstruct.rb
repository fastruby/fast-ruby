require "benchmark/ips"
require "ostruct"


Example = Struct.new(:field_1, :field_2)
Struct.new('User', :field_1, :field_2)

def fastest_0
  Example.new(1, 2)
end

def fastest_1
  Struct::User.new(1, 2)
end

def fast_0
  Example.new(field_1: 1, field_2: 2)
end

def fast_1
  Struct::User.new(field_1: 1, field_2: 2)
end

def fast_2
  { field_1: 1, field_2: 2 }
end

def slow
  OpenStruct.new(field_1: 1, field_2: 2)
end

Benchmark.ips do |x|
  x.report("Hash")                            { fast_2 }
  x.report("OpenStruct")                      { slow }
  x.report("Struct")                          { fastest_0 }
  x.report("Struct with named params")        { fast_0 }
  x.report("named Struct")                    { fastest_1 }
  x.report("named Struct with named params")  { fast_1 }
  x.compare!
end
