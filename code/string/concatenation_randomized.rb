require 'benchmark'

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
    @rand_strs[:lt10] = Array.new(RND_STRINGS_AMOUNT) { chars.sample(rand(10)).join }
    @rand_strs[:lt100] = Array.new(RND_STRINGS_AMOUNT) { chars.sample(rand(100)).join }
    @rand_strs[:lt1000] = Array.new(RND_STRINGS_AMOUNT) { chars.sample(rand(1000)).join }
    @rand_strs[:eq10] = Array.new(RND_STRINGS_AMOUNT) { chars.sample(10).join }
    @rand_strs[:eq100] = Array.new(RND_STRINGS_AMOUNT) { chars.sample(100).join }
  end

  self.generate_rand_strs

  def self.rand_str(named_range)
    @rand_strs[named_range][rand(RND_STRINGS_AMOUNT)]
  end

  def self.method_missing(symbol)
    return super unless @rand_strs.keys.include?(symbol)

    define_singleton_method(symbol) { rand_str(symbol) }
    return rand_str(symbol)
  end

end


# 2 + 1 = 3 object
def fastest_plus(foo, bar)
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

# bench_100_to_100
# Rehearsal -----------------------------------------------------------
# String#+                  1.263725   0.027868   1.291593 (  1.292498)
# "#{foo}#{bar}"            1.139442   0.022956   1.162398 (  1.163574)
# String#concat             2.017746   0.014836   2.032582 (  2.034682)
# String#append             1.320778   0.000000   1.320778 (  1.321896)
# Collateral actions only   0.713309   0.000000   0.713309 (  0.714402)
# -------------------------------------------------- total: 6.520660sec
#
#                           user     system      total        real         nomalized    ratio
# Collateral actions only   0.703668   0.000000   0.703668 (  0.705658)
# String#+                  1.014123   0.000000   1.014123 (  1.015003)    0.30934
# "#{foo}#{bar}"            1.101751   0.000585   1.102336 (  1.103558)    0.3979      x 1.3 slower
# String#concat             1.382647   0.000000   1.382647 (  1.385333)    0.679675    x 2.2 slower
# String#append             1.319974   0.000000   1.319974 (  1.324772)    0.619114    x 2 slower

def bench_100_to_100
  Benchmark.bmbm do |x|
    # 1M for rehearsal + 1M for bm
    sarr1 = Array.new(2_000_000) { RandStr.eq100.dup }
    sarr2 = Array.new(2_000_000) { RandStr.eq100.dup }

    i, j = 0, 0
    # if we want compare apples with apples, we need to measure and exclude "collateral" operations:
    # integer += 1, access to an array of randomized strings 100 symbols length,
    # then two methods invocation from RandStr module eq100 / lt100.
    #
    # and only then we can compare string concat methods properly
    x.report("Collateral actions only")  { k=0; 1_000_000.times { k+=1; RandStr.eq100; sarr2[k]; RandStr.lt100; } }

    x.report("String#+")        { k=0; 1_000_000.times { k+=1; sarr1[k]; fastest_plus(RandStr.eq100, RandStr.lt100) } }
    x.report('"#{foo}#{bar}"')  { k=0; 1_000_000.times { k+=1; sarr2[k]; fast_interpolation(RandStr.eq100, RandStr.lt100) } }
    x.report("String#concat")   { 1_000_000.times { RandStr.eq100; slow_concat(sarr1[i], RandStr.lt100); i+=1; } }
    x.report("String#append")   { 1_000_000.times { RandStr.eq100; slow_append(sarr2[j], RandStr.lt100); j+=1; } }
  end
end

# bench_100_to_1000
# Rehearsal -----------------------------------------------------------
# Collateral actions only   0.674168   0.000016   0.674184 (  0.675031)
# String#+                  2.148756   0.032954   2.181710 (  2.187042)
# "#{foo}#{bar}"            1.570816   0.004948   1.575764 (  1.579080)
# String#concat             2.223220   0.160917   2.384137 (  2.387601)
# String#append             2.005056   0.202962   2.208018 (  2.211476)
# -------------------------------------------------- total: 9.023813sec
#
#                           user     system      total        real         nomalized    ratio
# Collateral actions only   0.666190   0.000000   0.666190 (  0.666398)
# String#+                  1.077629   0.036944   1.114573 (  1.115465)     0.449067
# "#{foo}#{bar}"            1.230489   0.001029   1.231518 (  1.232423)     0.566025    x 1.25 slower
# String#concat             1.881313   0.149949   2.031262 (  2.033965)     1.367567    x 3.05 slower
# String#append             1.913785   0.177921   2.091706 (  2.094298)     1.4279      x 3.18 slower

def bench_100_to_1000
  Benchmark.bmbm do |x|
    sarr1 = Array.new(2_000_000) { RandStr.eq100.dup }
    sarr2 = Array.new(2_000_000) { RandStr.eq100.dup }

    i, j = 0, 0
    x.report("Collateral actions only")  { k=0; 1_000_000.times { k+=1; RandStr.eq100; sarr2[k]; RandStr.lt1000; } }

    x.report("String#+")        { k=0; 1_000_000.times { k+=1; sarr1[k]; fastest_plus(RandStr.eq100, RandStr.lt1000) } }
    x.report('"#{foo}#{bar}"')  { k=0; 1_000_000.times { k+=1; sarr2[k]; fast_interpolation(RandStr.eq100, RandStr.lt1000) } }
    x.report("String#concat")   { 1_000_000.times { RandStr.eq100; slow_concat(sarr1[i], RandStr.lt1000); i+=1; } }
    x.report("String#append")   { 1_000_000.times { RandStr.eq100; slow_append(sarr2[j], RandStr.lt1000); j+=1; } }
  end
end

# bench_10_to_100
# Rehearsal -----------------------------------------------------------
# Collateral actions only   0.681273   0.000000   0.681273 (  0.681611)
# String#+                  1.188326   0.000701   1.189027 (  1.196455)
# "#{foo}#{bar}"            1.182554   0.003851   1.186405 (  1.191678)
# String#concat             1.707191   0.006764   1.713955 (  1.720055)
# String#append             1.177368   0.000831   1.178199 (  1.184116)
# -------------------------------------------------- total: 5.948859sec
#
#                           user     system      total        real         nomalized    ratio
# Collateral actions only   0.682486   0.000000   0.682486 (  0.682818)
# String#+                  0.914002   0.000000   0.914002 (  0.917294)    0.234476
# "#{foo}#{bar}"            1.096633   0.000966   1.097599 (  1.100782)    0.417964     x 1.78 slower
# String#concat             1.373582   0.000910   1.374492 (  1.375239)    0.692421     x 2.95 slower
# String#append             1.300632   0.000000   1.300632 (  1.300807)    0.617989     x 2.63 slower

def bench_10_to_100
  Benchmark.bmbm do |x|
    sarr1 = Array.new(2_000_000) { RandStr.eq100.dup }
    sarr2 = Array.new(2_000_000) { RandStr.eq100.dup }
  
    i, j = 0, 0
    x.report("Collateral actions only")  { k=0; 1_000_000.times { k+=1; RandStr.eq10; sarr2[k]; RandStr.lt100; } }
    x.report("String#+")         { k=0; 1_000_000.times { k+=1; sarr1[k]; fastest_plus(RandStr.eq10, RandStr.lt100) } }
    x.report('"#{foo}#{bar}"')   { k=0; 1_000_000.times { k+=1; sarr2[k]; fast_interpolation(RandStr.eq10, RandStr.lt100) } }
    x.report("String#concat")    { 1_000_000.times { RandStr.eq10; slow_concat(sarr1[i], RandStr.lt100); i+=1; } }
    x.report("String#append")    { 1_000_000.times { RandStr.eq10; slow_append(sarr2[j], RandStr.lt100); j+=1;  } }
  end
end

