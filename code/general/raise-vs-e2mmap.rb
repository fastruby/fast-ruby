require 'benchmark/ips'
require 'e2mmap'

class WithE2MM
  extend Exception2MessageMapper

  def_e2message TypeError, 'argument must be a %s'
  def_exception :FooError, 'foo: %s'

  def self.raise_ruby_defined
    Raise TypeError, 'Hash'
  end

  def self.raise_user_defined
    Raise FooError, 'bar!'
  end
end

class WithoutE2MM
  FooError = Class.new(StandardError)

  def self.raise_ruby_defined
    raise TypeError, 'argument must be a Hash'
  end

  def self.raise_user_defined
    raise FooError, 'foo: bar!'
  end
end

def slow_ruby_defined
  begin
    WithE2MM.raise_ruby_defined
  rescue
    'fast ruby'
  end
end

def fast_ruby_defined
  begin
    WithoutE2MM.raise_ruby_defined
  rescue
    'fast ruby'
  end
end

def slow_user_defined
  begin
    WithE2MM.raise_user_defined
  rescue
    'fast ruby'
  end
end

def fast_user_defined
  begin
    WithoutE2MM.raise_user_defined
  rescue
    'fast ruby'
  end
end

Benchmark.ips do |x|
  x.report('Ruby exception: E2MM#Raise')   { slow_ruby_defined }
  x.report('Ruby exception: Kernel#raise') { fast_ruby_defined }
  x.compare!
end

Benchmark.ips do |x|
  x.report('Custom exception: E2MM#Raise')   { slow_user_defined }
  x.report('Custom exception: Kernel#raise') { fast_user_defined }
  x.compare!
end
