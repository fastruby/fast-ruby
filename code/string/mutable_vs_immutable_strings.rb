require 'benchmark/ips'

IMMUTABLE_TEST = "writing_fast_ruby".freeze
mutable_test = "writing_fast_ruby"

hash = {"writing_fast_ruby" => "is_cool"}

Benchmark.ips do |x|
  x.report("freeze") { hash[IMMUTABLE_TEST] }
  x.report("normal") { hash[mutable_test] }
  x.compare!
end
