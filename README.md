**GitHub currently disable the rendering of emoji in large document, that's why you see these strange `::` stuff.**

Fast Ruby :dash: :dash: :dash: :rocket: [![Build Status](https://travis-ci.org/JuanitoFatas/fast-ruby.svg?branch=travis)](https://travis-ci.org/JuanitoFatas/fast-ruby)
=======================================================================================================================================================================

In [Erik Michaels-Ober](https://github.com/sferik)'s great talk Writing Fast Ruby: [Video @ Baruco 2014](https://www.youtube.com/watch?v=fGFM_UrSp70), [Slide](https://speakerdeck.com/sferik/writing-fast-ruby), he presents us many idioms that leads to Faster Ruby. He inspired me and I want to document these to let more people know. I try to link to real commit for people to see this can really benefits in real world. **But this does not mean you can always replace one with another, depends on the context (e.g. `gsub` versus `tr`). :warning: Use with caution!**

Each idiom has a corresponding code example resides in [code](code).

All results listed in README.md :running: with Ruby 2.2.0p0 on OS X 10.10.1. Machine information: MacBook Pro (Retina, 15-inch, Mid 2014), 2.5 GHz Intel Core i7, 16 GB 1600 MHz DDR3. Your results may vary but you get the idea. : )

**Let's write faster code, together! <3**

:two_men_holding_hands: :two_women_holding_hands: :two_men_holding_hands: :two_men_holding_hands: :two_women_holding_hands: :couple: :two_women_holding_hands: :two_men_holding_hands: :two_women_holding_hands: :couple: :two_men_holding_hands: :couple: :dancers: :couple: :two_men_holding_hands: :two_men_holding_hands: :two_men_holding_hands: :two_men_holding_hands: :couple: :two_men_holding_hands: :two_women_holding_hands: :two_women_holding_hands: :couple: :couple: :two_men_holding_hands: :two_women_holding_hands: :two_men_holding_hands: :dancers: :couple:

Measurement Tool
-----------------

Use [benchmark-ips](https://github.com/evanphx/benchmark-ips).

### Template

```ruby
require 'benchmark/ips'

def slow
end

def fast
end

Benchmark.ips do |x|
  x.report('slow') { slow }
  x.report('fast') { fast }
  x.compare!
end
```

Idioms
------

### General

##### Parallel Assignment vs Sequential Assignment [code](code/general/assignment.rb)

> Parallel Assignment allocates an extra array.

```
$ ruby -v code/general/assignment.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
 Parallel Assignment     99.146k i/100ms
Sequential Assignment   127.143k i/100ms
-------------------------------------------------
 Parallel Assignment      2.522M (± 7.5%) i/s -     12.592M
Sequential Assignment     5.686M (± 8.6%) i/s -     28.226M

Comparison:
Sequential Assignment:  5685750.0 i/s
 Parallel Assignment:   2521708.9 i/s - 2.25x slower
```

##### `begin...rescue` vs `respond_to?` for Control Flow [code](code/general/begin-rescue-vs-respond-to.rb)

```
$ ruby -v code/general/begin-rescue-vs-respond-to.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
      begin...rescue    29.452k i/100ms
         respond_to?   106.528k i/100ms
-------------------------------------------------
      begin...rescue    371.591k (± 5.4%) i/s -      1.855M
         respond_to?      3.277M (± 7.5%) i/s -     16.299M

Comparison:
         respond_to?:  3276972.3 i/s
      begin...rescue:   371591.0 i/s - 8.82x slower
```

##### `define_method` vs `module_eval` for Defining Methods [code](code/general/define_method-vs-module-eval.rb)

```
$ ruby -v code/general/define_method-vs-module-eval.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
module_eval with string 125.000  i/100ms
       define_method    138.000  i/100ms
-------------------------------------------------
module_eval with string   1.130k (±20.3%) i/s -      5.500k
       define_method      1.346k (±25.9%) i/s -      6.348k

Comparison:
       define_method:        1345.6 i/s
module_eval with string:     1129.7 i/s - 1.19x slower
```

### Array

##### `Array#bsearch` vs `Array#find` [code](code/array/bsearch-vs-find.rb)

```
$ ruby -v code/array/bsearch-vs-find.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
                find     1.000  i/100ms
             bsearch    42.216k i/100ms
-------------------------------------------------
                find      0.184  (± 0.0%) i/s -      1.000  in   5.434758s
             bsearch    577.301k (± 6.6%) i/s -      2.913M

Comparison:
             bsearch:   577300.7 i/s
                find:        0.2 i/s - 3137489.63x slower
```

##### `Array#count` vs `Array#size` [code](code/array/count-vs-size.rb)

```
$ ruby -v code/array/count-vs-size.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
              #count   130.991k i/100ms
               #size   135.312k i/100ms
-------------------------------------------------
              #count      6.697M (± 7.1%) i/s -     33.403M
               #size      7.562M (± 9.1%) i/s -     37.481M

Comparison:
               #size:  7562457.4 i/s
              #count:  6696763.0 i/s - 1.13x slower
```

##### `Array#shuffle.first` vs `Array#sample` [code](code/array/shuffle-first-vs-sample.rb)

> `Array#shuffle` allocates an extra array. <br>
> `Array#sample` indexes into the array without allocating an extra array. <br>
> This is the reason why Array#sample exists. <br>
> —— @sferik [rails/rails#17245](https://github.com/rails/rails/pull/17245)

```
$ ruby -v code/array/shuffle-first-vs-sample.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
 Array#shuffle.first    25.406k i/100ms
        Array#sample   125.101k i/100ms
-------------------------------------------------
 Array#shuffle.first    304.341k (± 4.3%) i/s -      1.524M
        Array#sample      5.727M (± 8.6%) i/s -     28.523M

Comparison:
        Array#sample:  5727032.0 i/s
 Array#shuffle.first:   304341.1 i/s - 18.82x slower
```


### Enumerable

##### `Enumerable#each + push` vs `Enumerable#map` [code](code/enumerable/each-push-vs-map.rb)

```
$ ruby -v code/enumerable/each-push-vs-map.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
   Array#each + push     9.025k i/100ms
           Array#map    13.947k i/100ms
-------------------------------------------------
   Array#each + push     99.634k (± 3.2%) i/s -    505.400k
           Array#map    158.091k (± 4.2%) i/s -    794.979k

Comparison:
           Array#map:   158090.9 i/s
   Array#each + push:    99634.2 i/s - 1.59x slower
```

##### `Enumerable#each` vs `for` loop [code](code/array/each-vs-for-loop.rb)

```
$ ruby -v code/enumerable/each-vs-for-loop.rb
ruby 2.2.0preview1 (2014-09-17 trunk 47616) [x86_64-darwin14]

Calculating -------------------------------------
            For loop    17.111k i/100ms
               #each    18.464k i/100ms
-------------------------------------------------
            For loop    198.517k (± 5.3%) i/s -    992.438k
               #each    208.157k (± 5.0%) i/s -      1.052M

Comparison:
               #each:   208157.4 i/s
            For loop:   198517.3 i/s - 1.05x slower
```

##### `Enumerable#each_with_index` vs `while` loop [code](code/enumerable/each_with_index-vs-while-loop.rb)

> [rails/rails#12065](https://github.com/rails/rails/pull/12065)

```
$ ruby -v code/array/each_with_index-vs-while-loop.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
     each_with_index    11.496k i/100ms
          While Loop    20.179k i/100ms
-------------------------------------------------
     each_with_index    128.855k (± 7.5%) i/s -    643.776k
          While Loop    242.344k (± 4.5%) i/s -      1.211M

Comparison:
          While Loop:   242343.6 i/s
     each_with_index:   128854.9 i/s - 1.88x slower
```

##### `Enumerable#map`...`Array#flatten` vs `Enumerable#flat_map` [code](code/enumerable/map-flatten-vs-flat_map.rb)

> -- @sferik [rails/rails@3413b88](https://github.com/rails/rails/commit/3413b88), [Replace map.flatten with flat_map](https://github.com/rails/rails/commit/817fe31196dd59ee31f71ef1740122b6759cf16d), [Replace map.flatten(1) with flat_map](https://github.com/rails/rails/commit/b11ebf1d80e4fb124f0ce0448cea30988256da59)

```
ruby -v code/enumerable/map-flatten-vs-flat_map.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
Array#map.flatten(1)     3.315k i/100ms
   Array#map.flatten     3.283k i/100ms
      Array#flat_map     5.350k i/100ms
-------------------------------------------------
Array#map.flatten(1)     33.801k (± 4.3%) i/s -    169.065k
   Array#map.flatten     34.530k (± 6.0%) i/s -    173.999k
      Array#flat_map     55.980k (± 5.0%) i/s -    283.550k

Comparison:
      Array#flat_map:    55979.6 i/s
   Array#map.flatten:    34529.6 i/s - 1.62x slower
Array#map.flatten(1):    33800.6 i/s - 1.66x slower
```

##### `Enumerable#reverse.each` vs `Enumerable#reverse_each` [code](code/enumerable/reverse-each-vs-reverse_each.rb)

> `Enumerable#reverse` allocates an extra array.  <br>
> `Enumerable#reverse_each` yields each value without allocating an extra array. <br>
> This is the reason why `Enumerable#reverse_each` exists. <br>
> -- @sferik [rails/rails#17244](https://github.com/rails/rails/pull/17244)

```
$ ruby -v code/enumerable/reverse-each-vs-reverse_each.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
  Array#reverse.each    16.746k i/100ms
  Array#reverse_each    18.590k i/100ms
-------------------------------------------------
  Array#reverse.each    190.729k (± 4.8%) i/s -    954.522k
  Array#reverse_each    216.060k (± 4.3%) i/s -      1.078M

Comparison:
  Array#reverse_each:   216060.5 i/s
  Array#reverse.each:   190729.1 i/s - 1.13x slower
```

##### `Enumerable#detect` vs `Enumerable#select.first` [code](code/enumerable/select-first-vs-detect.rb)

```
$ ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
Enumerable#select.first  8.515k i/100ms
   Enumerable#detect    33.885k i/100ms
-------------------------------------------------
Enumerable#select.first  89.757k (± 5.0%) i/s -      1.797M
   Enumerable#detect    434.304k (± 5.2%) i/s -      8.675M

Comparison:
   Enumerable#detect:   434304.2 i/s
Enumerable#select.first:    89757.4 i/s - 4.84x slower
```

##### `Enumerable#sort` vs `Enumerable#sort_by` [code](code/enumerable/sort-vs-sort_by.rb)

```
$ ruby -v code/enumerable/sort-vs-sort_by.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
     Enumerable#sort     1.158k i/100ms
  Enumerable#sort_by     2.401k i/100ms
-------------------------------------------------
     Enumerable#sort     12.140k (± 4.9%) i/s -     61.374k
  Enumerable#sort_by     24.169k (± 4.0%) i/s -    122.451k

Comparison:
  Enumerable#sort_by:    24168.9 i/s
     Enumerable#sort:    12139.8 i/s - 1.99x slower
```


### Hash

##### `Hash#[]` vs `Hash#dup` [code](code/hash/bracket-vs-dup.rb)

Source: http://tenderlovemaking.com/2015/02/11/weird-stuff-with-hashes.html

> Does this mean that you should switch to Hash[]?
> Only if your benchmarks can prove that it’s a bottleneck.
> Please please please don’t change all of your code because
> this shows it’s faster. Make sure to measure your app performance first.

```
$ ruby -v code/hash/bracket-vs-dup.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
              Hash[]    29.403k i/100ms
            Hash#dup    16.195k i/100ms
-------------------------------------------------
              Hash[]    343.987k (± 8.7%) i/s -      1.735M
            Hash#dup    163.516k (±10.2%) i/s -    825.945k

Comparison:
              Hash[]:   343986.5 i/s
            Hash#dup:   163516.3 i/s - 2.10x slower
```

##### `Hash#fetch` with argument vs `Hash#fetch` + block [code](code/hash/fetch-vs-fetch-with-block.rb)

```
$ ruby -v code/hash/fetch-vs-fetch-with-block.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
    Hash#fetch + arg    15.650k i/100ms
  Hash#fetch + block   130.271k i/100ms
-------------------------------------------------
    Hash#fetch + arg    184.562k (± 5.2%) i/s -    923.350k
  Hash#fetch + block      5.880M (± 7.5%) i/s -     29.311M

Comparison:
  Hash#fetch + block:  5880209.2 i/s
    Hash#fetch + arg:   184562.0 i/s - 31.86x slower
```

##### `Hash#each_key` instead of `Hash#keys.each` [code](code/hash/keys-each-vs-each_key.rb)

> `Hash#keys.each` allocates an array of keys;  <br>
> `Hash#each_key` iterates through the keys without allocating a new array.  <br>
> This is the reason why `Hash#each_key` exists.  <br>
> —— @sferik [rails/rails#17099](https://github.com/rails/rails/pull/17099)

```
$ ruby -v code/hash/keys-each-vs-each_key.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
      Hash#keys.each    56.690k i/100ms
       Hash#each_key    59.658k i/100ms
-------------------------------------------------
      Hash#keys.each    869.262k (± 5.0%) i/s -      4.365M
       Hash#each_key      1.049M (± 6.0%) i/s -      5.250M

Comparison:
       Hash#each_key:  1049161.6 i/s
      Hash#keys.each:   869262.3 i/s - 1.21x slower
```

##### `Hash#merge!` vs `Hash#[]=` [code](code/hash/merge-bang-vs-\[\]=.rb)

```
$ ruby -v code/hash/merge-bang-vs-\[\]=.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
         Hash#merge!     1.023k i/100ms
            Hash#[]=     2.844k i/100ms
-------------------------------------------------
         Hash#merge!     10.653k (± 4.9%) i/s -     53.196k
            Hash#[]=     28.287k (±12.4%) i/s -    142.200k

Comparison:
            Hash#[]=:    28287.1 i/s
         Hash#merge!:    10653.3 i/s - 2.66x slower
```

##### `Hash#merge` vs `Hash#merge!` [code](code/hash/merge-vs-merge-bang.rb)

```
$ ruby -v code/hash/merge-vs-merge-bang.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
          Hash#merge    39.000  i/100ms
         Hash#merge!     1.008k i/100ms
-------------------------------------------------
          Hash#merge    409.610  (± 7.6%) i/s -      2.067k
         Hash#merge!      9.830k (± 5.8%) i/s -     49.392k

Comparison:
         Hash#merge!:     9830.3 i/s
          Hash#merge:      409.6 i/s - 24.00x slower
```


### Proc & Block

##### Block vs `Symbol#to_proc` [code](code/proc-and-block/block-vs-to_proc.rb)

> `Symbol#to_proc` is considerably more concise than using block syntax. <br>
> ...In some cases, it reduces the number of lines of code. <br>
> —— @sferik [rails/rails#16833](https://github.com/rails/rails/pull/16833)

```
$ ruby -v code/proc-and-block/block-vs-to_proc.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
               Block     4.632k i/100ms
      Symbol#to_proc     5.225k i/100ms
-------------------------------------------------
               Block     47.914k (± 6.3%) i/s -    240.864k
      Symbol#to_proc     54.791k (± 4.1%) i/s -    276.925k

Comparison:
      Symbol#to_proc:    54791.1 i/s
               Block:    47914.3 i/s - 1.14x slower
```

##### `Proc#call` vs `yield` [code](code/proc-and-block/proc-call-vs-yield.rb)

```
$ ruby -v code/proc-and-block/proc-call-vs-yield.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
          block.call    70.663k i/100ms
               yield   125.061k i/100ms
-------------------------------------------------
          block.call      1.309M (± 5.7%) i/s -      6.572M
               yield      6.103M (± 7.7%) i/s -     30.390M

Comparison:
               yield:  6102822.9 i/s
          block.call:  1309452.1 i/s - 4.66x slower
```


### String

##### `String#casecmp` vs `String#downcase + ==` [code](code/string/casecmp-vs-downcase-==.rb)

```
$ ruby -v code/string/casecmp-vs-downcase-\=\=.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
String#downcase + ==   101.900k i/100ms
      String#casecmp   109.828k i/100ms
-------------------------------------------------
String#downcase + ==      2.915M (± 5.4%) i/s -     14.572M
      String#casecmp      3.708M (± 6.1%) i/s -     18.561M

Comparison:
      String#casecmp:  3708258.7 i/s
String#downcase + ==:  2914767.7 i/s - 1.27x slower
```

##### String Concatenation [code](code/string/concatenation.rb)

```
$ ruby  code/string/concatenation.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
            String#+    96.314k i/100ms
       String#concat    99.850k i/100ms
       String#append   100.728k i/100ms
         "foo" "bar"   121.936k i/100ms
-------------------------------------------------
            String#+      2.731M (± 4.6%) i/s -     13.677M
       String#concat      2.847M (± 5.2%) i/s -     14.279M
       String#append      2.972M (± 6.1%) i/s -     14.807M
         "foo" "bar"      4.951M (± 6.2%) i/s -     24.753M

Comparison:
         "foo" "bar":  4950955.3 i/s
       String#append:  2972048.5 i/s - 1.67x slower
       String#concat:  2846666.4 i/s - 1.74x slower
            String#+:  2730980.7 i/s - 1.81x slower
```

##### `String#match` vs `String#start_with?`/`String#end_with?` [code (start)](code/string/start-string-checking-match-vs-start_with.rb) [code (end)](code/string/end-string-checking-match-vs-start_with.rb)

> :warning: <br>
> Sometimes you cant replace regexp with `start_with?`, <br>
> for example: `"a\nb" =~ /^b/ #=> 2` but `"a\nb" =~ /\Ab/ #=> nil`.<br>
> :warning: <br>
> You can combine `start_with?` and `end_with?` to replace
> `error.path =~ /^#{path}(\.rb)?$/` to this <br>
> `error.path.start_with?(path) && error.path.end_with?('.rb', '')`<br>
> —— @igas [rails/rails#17316](https://github.com/rails/rails/pull/17316)

```
$ ruby -v code/string/start-string-checking-match-vs-start_with.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
           String#=~    55.411k i/100ms
  String#start_with?   113.854k i/100ms
-------------------------------------------------
           String#=~    910.625k (± 4.6%) i/s -      4.544M
  String#start_with?      3.983M (± 5.5%) i/s -     19.924M

Comparison:
  String#start_with?:  3983284.9 i/s
           String#=~:   910625.0 i/s - 4.37x slower
```

```
$ ruby -v code/string/end-string-checking-match-vs-start_with.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
           String#=~    52.811k i/100ms
    String#end_with?   100.071k i/100ms
-------------------------------------------------
           String#=~    854.830k (± 5.8%) i/s -      4.278M
    String#end_with?      2.837M (± 5.5%) i/s -     14.210M

Comparison:
    String#end_with?:  2836536.9 i/s
           String#=~:   854830.3 i/s - 3.32x slower
```

##### `String#gsub` vs `String#sub` [code](code/string/gsub-vs-sub.rb)

```
$ ruby -v code/string/gsub-vs-sub.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
         String#gsub    35.724k i/100ms
          String#sub    42.426k i/100ms
-------------------------------------------------
         String#gsub    486.614k (± 5.4%) i/s -      2.429M
          String#sub    611.259k (± 4.6%) i/s -      3.055M

Comparison:
          String#sub:   611259.4 i/s
         String#gsub:   486613.5 i/s - 1.26x slower
```

##### `String#gsub` vs `String#tr` [code](code/string/gsub-vs-tr.rb)

> [rails/rails#17257](https://github.com/rails/rails/pull/17257)

```
$ ruby -v code/string/gsub-vs-tr.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]

Calculating -------------------------------------
         String#gsub    38.268k i/100ms
           String#tr    83.210k i/100ms
-------------------------------------------------
         String#gsub    516.604k (± 4.4%) i/s -      2.602M
           String#tr      1.862M (± 4.0%) i/s -      9.320M

Comparison:
           String#tr:  1861860.4 i/s
         String#gsub:   516604.2 i/s - 3.60x slower
```

##### `attr_accessor` vs `getter and setter` [code](code/general/attr-accessor-vs-getter-and-setter.rb)

> https://www.omniref.com/ruby/2.2.0/files/method.h?#annotation=4081781&line=47

```
$ ruby -v code/general/attr-accessor-vs-getter-and-setter.rb
ruby 2.2.0p0 (2014-12-25 revision 49005) [x86_64-darwin14]
Calculating -------------------------------------
   getter_and_setter    61.240k i/100ms
       attr_accessor    66.535k i/100ms
-------------------------------------------------
   getter_and_setter      1.660M (± 9.7%) i/s -      8.267M
       attr_accessor      1.865M (± 9.2%) i/s -      9.248M

Comparison:
       attr_accessor:  1865408.4 i/s
   getter_and_setter:  1660021.9 i/s - 1.12x slower
```

## Submit New Entry

Please! [Edit this README.md](https://github.com/JuanitoFatas/fast-ruby/edit/master/README.md) then [Submit a Awesome Pull Request](https://github.com/JuanitoFatas/fast-ruby/pulls)!

## Something went wrong

Code example is wrong? :cry: Got better example? :heart_eyes: Excellent!

[Please open an issue](https://github.com/JuanitoFatas/fast-ruby/issues/new) or [Open a Pull Request](https://github.com/JuanitoFatas/fast-ruby/pulls) to fix it.

Thank you in advance! :wink: :beer:


## One more thing

[Share this with your #Rubyfriends! <3](https://twitter.com/intent/tweet?url=http%3A%2F%2Fgit.io%2F4U3xdw&text=Fast%20Ruby%20--%20Common%20Ruby%20Idioms%20inspired%20by%20%40sferik&original_referer=&via=juanitofatas&hashtags=#RubyFriends)

Brought to you by [@JuanitoFatas](https://twitter.com/juanitofatas)

Feel free to talk with me on Twitter! <3

:gift_heart: :revolving_hearts: :gift_heart: :sparkling_heart: :blue_heart: :two_hearts: :heart: :heartpulse: :green_heart: :revolving_hearts: :heartbeat: :yellow_heart: :heartpulse: :heartbeat: :heart_decoration: :blue_heart: :hearts: :cupid: :hearts: :yellow_heart: :green_heart: :cupid: :heart: :heart: :yellow_heart: :purple_heart: :purple_heart: :heart_decoration: :sparkling_heart:


## Also Checkout

- [Benchmarking Ruby](https://speakerdeck.com/davystevenson/benchmarking-ruby)

- [davy/benchmark-bigo](https://github.com/davy/benchmark-bigo) - Provides Big O notation benchmarking for Ruby

- [The Ruby Challenge](https://therubychallenge.com/)


## License

![CC-BY-SA](CC-BY-SA.png)

This work is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-sa/4.0/).
