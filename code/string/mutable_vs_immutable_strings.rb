require "benchmark/ips"

# Keeps and reuses shared string
def fast
  "To freeze or not to freeze".freeze
end

# Allocates new string over and over again
def slow
  "To freeze or not to freeze"
end

Benchmark.ips do |x|
  x.report("With Freeze") { fast }
  x.report("Without Freeze") { slow }
  x.compare!
end
