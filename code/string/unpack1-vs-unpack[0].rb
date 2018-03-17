require 'benchmark/ips'

if RUBY_VERSION >= '2.4.0'
  STRING = "foobarbaz".freeze

  def fast
    STRING.unpack1('h*')
  end

  def slow
    STRING.unpack('h*')[0]
  end

  Benchmark.ips do |x|
    x.report('String#unpack1') { fast }
    x.report('String#unpack[0]') { slow }
    x.compare!
  end
end
