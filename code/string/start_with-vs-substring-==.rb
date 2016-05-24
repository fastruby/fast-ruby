require "benchmark/ips"

PREFIX = "_"
STRINGS = (0..9).map{|n| "#{PREFIX if n.odd?}#{n}" }

START_WITH = STRINGS.each_index.map do |i|
  "STRINGS[#{i}].start_with?(PREFIX)"
end.join(";")

EQL_USING_LENGTH = STRINGS.each_index.map do |i|
  # use `eql?` instead of `==` to prevent warnings
  "STRINGS[#{i}][0, PREFIX.length].eql?(PREFIX)"
end.join(";")

RANGE = 0...PREFIX.length

EQL_USING_RANGE_PREALLOC = STRINGS.each_index.map do |i|
  # use `eql?` instead of `==` to prevent warnings
  "STRINGS[#{i}][RANGE].eql?(PREFIX)"
end.join(";")

EQL_USING_RANGE = STRINGS.each_index.map do |i|
  # use `eql?` instead of `==` to prevent warnings
  "STRINGS[#{i}][0...PREFIX.length].eql?(PREFIX)"
end.join(";")

Benchmark.ips do |x|
  x.report("String#start_with?", START_WITH)
  x.report("String#[0, n] ==", EQL_USING_LENGTH)
  x.report("String#[RANGE] ==", EQL_USING_RANGE_PREALLOC)
  x.report("String#[0...n] ==", EQL_USING_RANGE)
  x.compare!
end
