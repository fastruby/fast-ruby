require 'benchmark/ips'

# Built once, so the benchmark measures defining the methods, not building names.
# Random names built on every call made garbage, and the GC paused at random moments.
METHOD_NAMES = Array.new(10) { |i| "method_#{i}" }

# Each call defines the 10 methods on a new, empty class, so every call does the same work.
# Adding them to one class that is never reset made late calls slower than early ones.
def fast
  Class.new do
    METHOD_NAMES.each do |method_name|
      define_method method_name do
        puts 'win'
      end
    end
  end
end

def slow
  Class.new do
    METHOD_NAMES.each do |method_name|
      module_eval %{
        def #{method_name}
          puts "win"
        end
      }
    end
  end
end

Benchmark.ips do |x|
  x.report('define_method')           { fast }
  x.report('module_eval with string') { slow }
  x.compare!
end
