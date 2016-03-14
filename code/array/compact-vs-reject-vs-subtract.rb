require 'benchmark/ips'

ARRAY = Array.new(1000){ rand(2).nonzero? }

def compact
  ARRAY.compact
end

def reject
  ARRAY.reject(&:nil?)
end

def subtract
  ARRAY - [nil]
end

Benchmark.ips do |x|
  x.report('A.compact') { compact }
  x.report('A.reject(&:nil?)') { reject }
  x.report('A - [nil]') { subtract }
  x.compare!
end
