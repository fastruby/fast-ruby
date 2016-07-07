require 'benchmark/ips'

hash = {foo: true, bar: true}

Benchmark.ips do |x|
  x.report("include? ") {|num|
    i = 0
    while i < num
      hash.include?(:foo)
      i += 1
    end

  }
  x.report("[] ") {|num|
    i = 0
    while i < num
      hash[:foo]
      i += 1
    end
  }
  x.compare!
end