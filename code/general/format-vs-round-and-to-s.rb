require 'benchmark/ips'

NUM = 1.12678.freeze

def fast
  NUM.round(2).to_s
end

def avg
  format('%.2f', NUM)
end

def slow
  '%.2f' % NUM
end

Benchmark.ips do |x|
  x.report('Float#round') { fast }
  x.report('Kernel#format') { avg }
  x.report('String#%') { slow }
  x.compare!
end
