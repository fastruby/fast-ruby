require "benchmark/ips"

NUMBER = 100_000_000

def fast
  index = 0
  while true
    break if index > NUMBER
    index += 1
  end
end

def slow
  index = 0
  loop do
    break if index > NUMBER
    index += 1
  end
end

Benchmark.ips do |x|
  x.report("While Loop")  { fast }
  x.report("Kernel loop") { slow }
  x.compare!
end
