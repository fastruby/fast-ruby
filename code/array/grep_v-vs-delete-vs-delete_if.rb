require 'benchmark/ips'

ARRAY = Array.new(1000){ rand(2).nonzero? }
ARRAY1 = ARRAY.dup
ARRAY2 = ARRAY.dup
ARRAY3 = ARRAY.dup

def grep_v
  ARRAY1.grep_v(nil)
end

def delete
  ARRAY2.delete(nil)
end

def delete_if
  ARRAY3.delete_if(&:nil?)
end

Benchmark.ips do |x|
  x.report('A.grep_v(nil)') { grep_v }
  x.report('A.delete(nil)') { delete }
  x.report('A.delete_if(&:nil?)') { delete_if }
  x.compare!
end
