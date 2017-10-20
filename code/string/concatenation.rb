require 'benchmark/ips'

# 1 object
def faster
  'foo' 'bar'
end

def fast
  "#{'foo'}#{'bar'}"
end

# 2 + 1 = 3 object
def slow
  'foo' << 'bar'
end

# 2 + 1 = 3 object
def slower
  'foo' + 'bar'
end

# 2 + 1 = 3 object
def slowest
  'foo'.concat 'bar'
end


Benchmark.ips(quiet: true) do |x|
  x.report('"foo" "bar"           ') { faster  }
  x.report('"#{\'foo\'}#{\'bar\'}"') { fast    }
  x.report('String#append         ') { slow    }
  x.report('String#+              ') { slower  }
  x.report('String#concat         ') { slowest }
  x.compare!
end
