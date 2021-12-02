require 'benchmark/ips'

ENUM = (1..100)
HASH = ENUM.to_h{ |a| [a, a]}
SECOND_HASH = ENUM.to_h{ |a| [a+50, a+50]}

def merge
  h = HASH
  h.merge!(SECOND_HASH)
end

def assign
  ENUM.each_with_object({}) do |e, h|
    h[e] = e
  end
end

Benchmark.ips do |x|
  x.report('Hash#merge!') { merge }
  x.report('Hash#[]=') { assign }
  x.compare!
end
