require 'benchmark/ips'

User = Struct.new(:name)
ARRAY = Array.new(100) do
  User.new(sprintf "%010d", rand(1_000_000_000))
end

def slow
  ARRAY.sort { |a,b| a.name <=> b.name }
end

def fast
  ARRAY.sort_by { |a| a.name }
end

Benchmark.ips do |x|
  x.report('Enumerable#sort')    { slow }
  x.report('Enumerable#sort_by') { fast }
  x.compare!
end
