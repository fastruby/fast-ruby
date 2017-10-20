require 'benchmark/ips'

SLUG = 'root_url'

def fast
  SLUG.end_with?('_path', '_url')
end

def slow
  SLUG =~ /_(path|url)$/
end

Benchmark.ips(quiet: true) do |x|
  x.report('String#end_with?') { fast }
  x.report('String#=~       ') { slow }
  x.compare!
end
