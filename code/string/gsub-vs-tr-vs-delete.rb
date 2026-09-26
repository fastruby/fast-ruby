require 'benchmark/ips'

WORDS = 'writing fast ruby'
SPACE = ' '

# The same call as `faster`, but ' ' is allocated once instead of on every call.
def fastest
  WORDS.delete(SPACE)
end

def faster
  WORDS.delete(' ')
end

def fast
  WORDS.tr(' ', '')
end

def slow
  WORDS.gsub(' ', '')
end

Benchmark.ips do |x|
  x.report('String#delete const') { fastest }
  x.report('String#delete') { faster }
  x.report('String#tr') { fast }
  x.report('String#gsub') { slow }
  x.compare!
end
