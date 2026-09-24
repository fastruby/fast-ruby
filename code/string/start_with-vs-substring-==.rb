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

# Each check is written out for all 10 strings (not looped), so only the checks are measured.
# The methods are defined from those strings.
eval "def fastest\n#{START_WITH}\nend"
eval "def faster\n#{EQL_USING_LENGTH}\nend"
eval "def fast\n#{EQL_USING_RANGE_PREALLOC}\nend"
eval "def slow\n#{EQL_USING_RANGE}\nend"

Benchmark.ips do |x|
  x.report("String#start_with?") { fastest }
  x.report("String#[0, n] ==") { faster }
  x.report("String#[RANGE] ==") { fast }
  x.report("String#[0...n] ==") { slow }
  x.compare!
end
