require 'benchmark/ips'
require 'e2mmap'

# Defines and raises an exception class of its own (FooError).
# For an exception class Ruby already defines, see raise-vs-e2mmap.rb.

class WithE2MM
  extend Exception2MessageMapper

  def_exception :FooError, 'foo: %s'

  def self.raise_user_defined
    Raise FooError, 'bar!'
  end
end

class WithoutE2MM
  FooError = Class.new(StandardError)

  def self.raise_user_defined
    raise FooError, 'foo: bar!'
  end
end

def fast
  begin
    WithoutE2MM.raise_user_defined
  rescue
    'fast ruby'
  end
end

def slow
  begin
    WithE2MM.raise_user_defined
  rescue
    'fast ruby'
  end
end

Benchmark.ips do |x|
  x.report('Custom exception: Kernel#raise') { fast }
  x.report('Custom exception: E2MM#Raise')   { slow }
  x.compare!
end
