require 'benchmark/ips'

USER = Struct.new(:id, :stuff)
ARRAY = Array.new(1000) { |element| USER.new(element, stuff: rand(1000)) }

def fast
  ARRAY.each_with_object({}) { |element, result| result[element.id] = element.stuff }
end

def slow
  ARRAY.inject({}) { |result, element| result[element.id] = element.stuff; result }
end

Benchmark.ips do |x|
  x.report('Enumerable#each_with_object') { fast }
  x.report('Enumerable#inject') { slow }
  x.compare!
end