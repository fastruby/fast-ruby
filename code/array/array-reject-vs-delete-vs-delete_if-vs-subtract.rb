require 'benchmark/ips'

ARRAY = [nil]*1000

def reject
  ARRAY.reject { |o| o.nil? }
end

def delete
  ARRAY.delete(nil)
end

def delete_if
  ARRAY.delete_if(&:nil?)
end

def subtract
  ARRAY - [nil]
end

Benchmark.ips do |x|
  x.report('A.reject{|o|o.nil?}') { reject }
  x.report('A.delete(nil)') { delete }
  x.report('A.delete_if(&:nil?)') { delete_if }
  x.report('A - [nil]') { subtract }
  x.compare!
end
