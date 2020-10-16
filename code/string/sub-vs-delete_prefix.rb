require "benchmark/ips"

if RUBY_VERSION >= '2.5.0'
  STRING = 'Foo::Foo::Bar'.freeze

  def fast
    STRING.delete_prefix('Foo::')
  end

  def slow
    STRING.sub(/\AFoo::/, '')
  end

  Benchmark.ips do |x|
    x.report("String#delete_prefix") { fast }
    x.report('String#sub') { slow }
    x.compare!
  end
end
