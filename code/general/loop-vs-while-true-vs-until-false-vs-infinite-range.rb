require "benchmark/ips"

NUMBER = 100_000_000

def fastest
  index = 0
  while true
    break if index > NUMBER
    index += 1
  end
end

def fast
  index = 0
  until false
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

def slowest
  (0..).each do |index|
    break if index > NUMBER
  end
end

Benchmark.ips do |x|
  x.report("While loop") { fastest }
  x.report("Until loop") { fast }
  x.report("Kernel loop") { slow }
  x.report("Infinite range") { slowest }
  x.compare!
end
