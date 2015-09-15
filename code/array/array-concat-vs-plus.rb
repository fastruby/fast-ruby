require 'benchmark/ips'

data = [ nil ]
frozen_data = [ nil ].freeze

Benchmark.ips do |x|
  x.report('array.concat(array)')   { data.concat(frozen_data) }
  x.report('array + array')         { data + frozen_data    }
  x.compare!
end
