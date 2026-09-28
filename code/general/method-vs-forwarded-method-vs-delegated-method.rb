require 'benchmark/ips'
require 'forwardable'
require 'delegate'

class AdvancedArray < SimpleDelegator
  def initialize(*args)
    @args = args
    self.__setobj__(@args)
  end

  def push(value)
    @args.push(value)
  end

  extend Forwardable
  def_delegator :@args, :push, :forwarded_push
end

def fast
  array = AdvancedArray.new
  array.push(1)               # Simple method call
end

def slow
  array = AdvancedArray.new
  array.forwarded_push(1)     # Forwarded method call
end

def slower
  array = AdvancedArray.new
  array << 1                  # Delegated method call (Array#<< through SimpleDelegator)
end

Benchmark.ips do |x|
  x.report('method') { fast }
  x.report('forwarded method') { slow }
  x.report('delegated method') { slower }
  x.compare!
end
