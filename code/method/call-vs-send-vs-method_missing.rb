require "benchmark/ips"

class MethodCall
  def method
  end

  def method_missing(_method,*args)
  	method
  end
end

def fastest
  method = MethodCall.new
  method.method
end

def slow
  method = MethodCall.new
  method.send(:method)
end

def slowest
  method = MethodCall.new
  method.not_exist
end

Benchmark.ips do |x|
  x.report("call")           { fastest }
  x.report("send")           { slow    }
  x.report("method_missing") { slowest }
  x.compare!
end
