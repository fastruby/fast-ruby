def avg
  Rational(2, 3)
end
def slow1
  Rational('2/3')
end

def slow2
  2/3r
end
def fast1
  2r/3
end
def fast2
  2r/3r
end

require 'benchmark/ips'
Benchmark.ips do |bm|
  bm.report('Rational(2, 3)') {avg}
  bm.report(%q"Rational('2/3')") {slow1}
  bm.report('2/3r') {slow2}
  bm.report('2r/3') {fast1}
  bm.report('2r/3r') {fast2}
  bm.compare!
end