require 'benchmark/ips'
require 'e2mmap'

# Raises an exception class Ruby already defines (TypeError).
# For an exception class defined in the file, see raise-custom-vs-e2mmap.rb.

class WithE2MM
  extend Exception2MessageMapper

  def_e2message TypeError, 'argument must be a %s'

  def self.raise_ruby_defined
    Raise TypeError, 'Hash'
  end
end

class WithoutE2MM
  def self.raise_ruby_defined
    raise TypeError, 'argument must be a Hash'
  end
end

def fast
  begin
    WithoutE2MM.raise_ruby_defined
  rescue
    'fast ruby'
  end
end

def slow
  begin
    WithE2MM.raise_ruby_defined
  rescue
    'fast ruby'
  end
end

Benchmark.ips do |x|
  x.report('Ruby exception: Kernel#raise') { fast }
  x.report('Ruby exception: E2MM#Raise')   { slow }
  x.compare!
end
