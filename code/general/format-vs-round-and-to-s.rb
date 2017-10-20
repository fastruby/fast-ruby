require 'benchmark/ips'

NUM = 1.12678.freeze

def fast
  NUM.round(2).to_s
end

def slow
  format('%.2f', NUM)
end

def slower
  '%.2f' % NUM
end

Benchmark.ips(quiet: true) do |x|
  x.report('Float#round  ') { fast }
  x.report('Kernel#format') { slow }
  x.report('String#%     ') { slower }
  x.compare!
end
