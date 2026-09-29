require 'benchmark/ips'

NUMBER = 100_000_000

# The three loops that test a condition tie on Ruby 4.0.
def fastest
  index = 0
  begin
    index += 1
  end until index > NUMBER
end

def faster
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

# Endless ranges are Ruby 2.6+ syntax, so the method is defined from a string, which older Rubies never parse.
if RUBY_VERSION >= '2.6.0'
  eval <<-RUBY
    def slower
      (0..).each do |index|
        break if index > NUMBER
      end
    end
  RUBY
end

Benchmark.ips do |x|
  x.report('Begin Until')    { fastest }
  x.report('While Loop')     { faster }
  x.report('Until loop')     { fast }
  x.report('Kernel loop')    { slow }
  x.report('Infinite range') { slower } if RUBY_VERSION >= '2.6.0'
  x.compare!
end
