require 'benchmark/ips'

NUM = 1.12678.freeze

def faster
  NUM.round(2).to_s
end

def fast
  format('%.2f', NUM)
end

def slow
  '%.2f' % NUM
end

Benchmark.ips do |x|
  x.report('Float#round') { faster }
  x.report('Kernel#format') { fast }
  x.report('String#%') { slow }
  x.compare!
end
