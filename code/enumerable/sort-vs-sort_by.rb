require "benchmark/ips"

User  = Struct.new(:name)
ARRAY = Array.new(100) do
  User.new(sprintf "%010d", rand(1_000_000_000))
end

# The two sort_by forms are close: Symbol#to_proc wins on plain CRuby, the block wins with YJIT and on JRuby.
def faster
  ARRAY.sort_by(&:name)
end

def fast
  ARRAY.sort_by { |element| element.name }
end

def slow
  ARRAY.sort { |a, b| a.name <=> b.name }
end

Benchmark.ips do |x|
  x.report('Enumerable#sort_by (Symbol#to_proc)') { faster }
  x.report('Enumerable#sort_by') { fast }
  x.report('Enumerable#sort')    { slow }
  x.compare!
end
