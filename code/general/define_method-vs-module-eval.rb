require 'benchmark/ips'

def method_names(number)
  number.times.map do
    10.times.inject("") { |e| e << ('a'..'z').to_a.sample}
  end
end

class DefineMethod
  def self.def_methods(_methods)
    _methods.each do |method_name|
      define_method method_name do
        puts "win"
      end
    end
  end
end

class ModuleEvalWithString
  def self.def_methods(_methods)
    _methods.each do |method_name|
      module_eval %{
        def #{method_name}
          puts "win"
        end
      }
    end
  end
end

def fast
  DefineMethod.def_methods(method_names(10))
end

def slow
  ModuleEvalWithString.def_methods(method_names(10))
end


Benchmark.ips do |x|
  x.report("module_eval with string") { slow }
  x.report("define_method")           { fast }
  x.compare!
end
