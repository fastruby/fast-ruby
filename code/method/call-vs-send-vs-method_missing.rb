require "benchmark/ips"

class MethodCall
  def method
  end

  def method_missing(_method,*args)
    method
  end
end

def fast
  method = MethodCall.new
  method.method
end

def slow
  method = MethodCall.new
  method.send(:method)
end

def slower
  method = MethodCall.new
  method.not_exist
end

Benchmark.ips(quiet: true) do |x|
  x.report("call          ") { fast   }
  x.report("send          ") { slow   }
  x.report("method_missing") { slower }
  x.compare!
end
