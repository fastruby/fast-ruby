require 'benchmark/ips'

ARRAY = Array.new(100_000){ rand(2).nonzero? }

ARRAY1 = ARRAY.dup
ARRAY2 = ARRAY.dup
ARRAY3 = ARRAY.dup
ARRAY4 = ARRAY.dup
ARRAY5 = ARRAY.dup
ARRAY6 = ARRAY.dup
ARRAY7 = ARRAY.dup
ARRAY8 = ARRAY.dup

def compact!
  ARRAY1.compact!
end

def compact
  ARRAY2.compact
end

def reject!
  ARRAY3.reject!(&:nil?)
end

def reject
  ARRAY4.reject(&:nil?)
end

def delete
  ARRAY5.delete(nil)
end

def delete_if
  ARRAY6.delete_if(&:nil?)
end

def subtract
  ARRAY7 - [nil]
end

def grep_v
  ARRAY8.grep_v(nil)
end

Benchmark.ips do |x|
  x.report('A.compact!') { compact! }
  x.report('A.compact') { compact }
  x.report('A.reject(&:nil?)') { reject }
  x.report('A.reject!(&:nil?)') { reject! }
  x.report('A.delete(nil)') { delete }
  x.report('A.delete_if(&:nil?)') { delete_if }
  x.report('A - [nil]') { subtract }
  x.report('A.grep_v(nil)') { grep_v }
  x.compare!
end
