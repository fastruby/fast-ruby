require 'benchmark/ips'

HASH = {
  title: "awesome",
  description: "a description",
  author: "styd",
  published_at: Time.now
}

HASH.dup.each{ |k, v| HASH[:"other_#{k}"], HASH[:"more_#{k}"] = v, v }

# Native implementation since v2.5
#
def fastest
  HASH.slice(*%i[title author other])
end

# @ixti's faster implementation than that of ActiveSupport below
#
# Source:
#   https://github.com/JuanitoFatas/fast-ruby/pull/173#issuecomment-470554483
#
def faster
  memo = {}
  %i[title author other].each { |k| memo[k] = HASH[k] if HASH.key?(k) }
  memo
end

# ActiveSupport implementation of `slice` when it's not defined.
#
# Source:
#   https://github.com/rails/rails/blob/01ae39660243bc5f0a986e20f9c9bff312b1b5f8/activesupport/lib/active_support/core_ext/hash/slice.rb#L24
#
def fast 
  %i[title author other].each_with_object({}){ |k, h| h[k] = HASH[k] if HASH.key?(k) }
end

def slow
  keys = %i[title author other]
  HASH.select { |k, _| keys.include? k }
end

Benchmark.ips do |x|
  x.report('Hash#native-slice   ') { fastest }
  x.report('Array#each          ') { faster }
  x.report('Array#each_w/_object') { fast }
  x.report('Hash#select-include ') { slow }
  x.compare!
end
