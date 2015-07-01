require 'benchmark/ips'

class MethodCall

	def method
	end

	def method_missing(mt,*args)
		method
	end
end

def fast
  mt = MethodCall.new
  mt.method
end

def slow
  mt = MethodCall.new
  mt.send(:method)
end

def slow_1
  mt = MethodCall.new
  mt.youknow
end

Benchmark.ips do |x|
  x.report("call")   { fast }
  x.report("send") { slow }
  x.report("method_missing") { slow_1 }
  x.compare!
end