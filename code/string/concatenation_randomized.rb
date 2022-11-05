require 'benchmark/ips'

module RandStr
  RND_STRINGS_AMOUNT = 1000
  @rand_strs = {
    lt100: [],
    lt10: [],
    lt1000: [],
    eq10: [],
    eq100: [],
  }

  def self.generate_rand_strs
    chars = ('A'..'z').to_a * 20
    RND_STRINGS_AMOUNT.times do
      @rand_strs[:lt10] << chars.sample( rand(10) ).join
      @rand_strs[:lt100] << chars.sample( rand(100) ).join
      @rand_strs[:lt1000] << chars.sample( rand(1000) ).join
      @rand_strs[:eq10] << chars.sample(10).join
      @rand_strs[:eq100] << chars.sample(100).join
    end
  end

  self.generate_rand_strs

  def self.rand_str( named_range )
    @rand_strs[named_range][rand(RND_STRINGS_AMOUNT)]
  end

  def self.method_missing(symbol)
    return super unless @rand_strs.keys.include?(symbol)

    define_singleton_method(symbol) { rand_str( symbol ) }
    return rand_str( symbol )
  end

end


# 2 + 1 = 3 object
def slow_plus(foo, bar)
  foo + bar
end

# 2 + 1 = 3 object
def slow_concat(foo, bar)
  foo.concat bar
end

# 2 + 1 = 3 object
def slow_append(foo, bar)
  foo << bar
end


def fast_interpolation(foo, bar)
  "#{foo}#{bar}"
end

def bench_100_to_100
  Benchmark.ips(2) do |x|
    sarr1, sarr2 = [], []
    (x.time * 5_000_000).times { sarr1 << RandStr.eq100.dup }
    (x.time * 5_000_000).times { sarr2 << RandStr.eq100.dup }

    i, j, k = 0, 0, 0
    x.report("String#+")                 { k+=1; sarr1[k]; slow_plus(RandStr.eq100, RandStr.lt100) }
    x.report('"#{\'foo\'}#{\'bar\'}"')   { k+=1; sarr2[k]; fast_interpolation(RandStr.eq100, RandStr.lt100) }
    x.report("String#concat")            { i+=1; RandStr.eq100; slow_concat(sarr1[i], RandStr.lt100) }
    x.report("String#append")            { j+=1; RandStr.eq100; slow_append(sarr2[j], RandStr.lt100) }
    x.compare!
  end; :done
end

def bench_100_to_1000
  Benchmark.ips(2) do |x|
    sarr1, sarr2 = [], []
    (x.time * 5_000_000).times { sarr1 << RandStr.eq100.dup }
    (x.time * 5_000_000).times { sarr2 << RandStr.eq100.dup }

    i, j, k = 0, 0, 0
    x.report("String#+")                 { k+=1; sarr1[k]; slow_plus(RandStr.eq100, RandStr.lt1000) }
    x.report('"#{\'foo\'}#{\'bar\'}"')   { k+=1; sarr2[k]; fast_interpolation(RandStr.eq100, RandStr.lt1000) }
    x.report("String#concat")            { i+=1; RandStr.eq100; slow_concat(sarr1[i], RandStr.lt1000) }
    x.report("String#append")            { j+=1; RandStr.eq100; slow_append(sarr2[j], RandStr.lt1000) }
    x.compare!
  end; :done
end

def bench_10_to_100
  Benchmark.ips(2) do |x|
    sarr1, sarr2 = [], []
    (x.time * 5_000_000).times { sarr1 << RandStr.eq10.dup }
    (x.time * 5_000_000).times { sarr2 << RandStr.eq10.dup }

    i, j, k = 0, 0, 0
    x.report("String#+")                 { k+=1; sarr1[k]; slow_plus(RandStr.eq10, RandStr.lt100) }
    x.report('"#{\'foo\'}#{\'bar\'}"')   { k+=1; sarr2[k]; fast_interpolation(RandStr.eq10, RandStr.lt100) }
    x.report("String#concat")            { i+=1; RandStr.eq10; slow_concat(sarr1[i], RandStr.lt100) }
    x.report("String#append")            { j+=1; RandStr.eq10; slow_append(sarr2[j], RandStr.lt100) }
    x.compare!
  end; :done
end

