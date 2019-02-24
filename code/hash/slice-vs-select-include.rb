require 'benchmark/ips'

HASH = {
  title: "awesome",
  description: "a description",
  author: "styd",
  published_at: Time.now
}

def fast
  HASH.slice(:title, :author)
end

def slow
  HASH.select {|k, _| [:title, :author].include? k }
end

Benchmark.ips do |x|
  x.report('Hash#slice') { fast }
  x.report('Hash#select_if_includes') { slow }
  x.compare!
end
