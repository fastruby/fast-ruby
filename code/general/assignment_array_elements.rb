require 'benchmark/ips'

def slow(env)
  status, headers, body = env
  headers.delete('Http-Access-Token')
  [status, headers, body]
end

def fast(env)
  env[1].delete('Http-Access-Token')
  env
end

env = [200, { 'Http-Access-Token' => '99d25f556b456d658ba0185540d9daa0' }, 'Hello ips']

Benchmark.ips do |x|
  x.report('element objects Assignment') { slow(env) }
  x.report('array Assignment') { fast(env) }
  x.compare!
end

def slow_ext(env)
  status, headers, body = env
  headers['X-Clacks-Overhead'] = 'GNU Terry Pratchett'
  [status, headers, body]
end

def fast_ext(env)
  env[1]['X-Clacks-Overhead'.freeze] = 'GNU Terry Pratchett'.freeze
  env
end

env = [200, { 'Http-Access-Token' => '99d25f556b456d658ba0185540d9daa0', 'X-Clacks-Overhead' => 'Cascade' }, 'Hello ips']

Benchmark.ips do |x|
  x.report('element objects Assignment') { slow_ext(env) }
  x.report('array Assignment') { fast_ext(env) }
  x.compare!
end
