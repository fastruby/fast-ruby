require 'benchmark/ips'

ARRAY = Array.new(1000){ rand(2).nonzero? }
ARRAY1 = ARRAY.dup
ARRAY2 = ARRAY.dup
ARRAY3 = ARRAY.dup
ARRAY4 = ARRAY.dup

def compact
  ARRAY1.compact
end

def compact!
  ARRAY2.compact
end

def reject
  ARRAY3.reject(&:nil?)
end

def subtract
  ARRAY4 - [nil]
end

Benchmark.ips do |x|
  x.report('A.compact') { compact }
  x.report('A.compact!') { compact! }
  x.report('A.reject(&:nil?)') { reject }
  x.report('A - [nil]') { subtract }
  x.compare!
end
