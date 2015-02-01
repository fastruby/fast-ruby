require 'benchmark/ips'

chars = ('a'..'z').to_a

ARRAY = 100.times.map do
  { :name => chars.sample(10).join('') }
end

def slow
  ARRAY.inject({}) { |m,p| m[p[:name]] = p; m }
end

def fast
  ARRAY.each_with_object({}) { |p,m| m[p[:name]] = p }
end

Benchmark.ips do |x|
  x.report('Enumerable#inject') 	  { slow }
  x.report('Enumerable#each_with_object') { fast }
  x.compare!
end
