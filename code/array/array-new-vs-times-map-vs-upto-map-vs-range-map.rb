require "benchmark/ips"

ELEMENTS = 9
MAX_INDEX = ELEMENTS - 1

def fastest
  Array.new(ELEMENTS) { |i| i }
end

def fast
  (0..MAX_INDEX).map { |i| i }
end

def slow
  0.upto(MAX_INDEX).map { |i| i }
end

def slowest
  ELEMENTS.times.map { |i| i }
end

Benchmark.ips do |x|
  x.report("Array#new") { fastest }
  x.report("range + map") { fast }
  x.report("Integer#upto + map") { slow }
  x.report("Integer#times + map") { slowest }
  x.compare!
end
