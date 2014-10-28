Fast Ruby :dash: :dash: :dash: :rocket: [![Build Status](https://travis-ci.org/JuanitoFatas/fast-ruby.svg?branch=travis)](https://travis-ci.org/JuanitoFatas/fast-ruby)
=======================================================================================================================================================================

In [Erik Michaels-Ober](https://github.com/sferik)'s great talk Writing Fast Ruby: [Video @ Baruco 2014](https://www.youtube.com/watch?v=fGFM_UrSp70), [Slide](https://speakerdeck.com/sferik/writing-fast-ruby), he presents us many idioms that leads to Faster Ruby. He inspired me and I want to document these to let more people know. I try to link to real commit for people to see this can really benefits in real world. **But this does not mean you can always replace one with another, depends on the context (e.g. `gsub` versus `tr`). :warning: Use with caution!**

Each idiom has a corresponding code example resides in [code](code).

All results :running: with Ruby 2.2.0-preview1 on OS X 10.9.4. Your results may vary but you get the idea. : )

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
ruby 2.2.0preview1 (2014-09-17 trunk 47616) [x86_64-darwin13]

Calculating -------------------------------------
 Parallel Assignment    113719 i/100ms
Sequential Assignment   145620 i/100ms

-------------------------------------------------
  Parallel Assignment 2927066.6 (±4.8%) i/s -   14669751 in   5.024304s
Sequential Assignment 6660499.7 (±4.5%) i/s -   33346980 in   5.018252s

Comparison:
Sequential Assignment:  6660499.7 i/s
  Parallel Assignment:  2927066.6 i/s - 2.28x slower
```

##### `begin...rescue` vs `respond_to?` for Control Flow [code](code/general/begin-rescue-vs-respond-to.rb)

```
$ ruby -v code/general/begin-rescue-vs-respond-to.rb
ruby 2.2.0preview1 (2014-09-17 trunk 47616) [x86_64-darwin13]

Calculating -------------------------------------
      begin...rescue     35978 i/100ms
         respond_to?    131419 i/100ms
-------------------------------------------------
      begin...rescue   474725.9 (±2.7%) i/s -    2374548 in   5.005720s
         respond_to?  3970459.3 (±3.4%) i/s -   19844269 in   5.004508s

Comparison:
         respond_to?:  3970459.3 i/s
      begin...rescue:   474725.9 i/s - 8.36x slower
```


### String

##### String Concatenation [code](code/string/concatenation.rb)

```
$ ruby  code/string/concatenation.rb
ruby 2.2.0preview1 (2014-09-17 trunk 47616) [x86_64-darwin13]

Calculating -------------------------------------
            String#+    112031 i/100ms
       String#concat    118035 i/100ms
       String#append    120165 i/100ms
         "foo" "bar"    143485 i/100ms
-------------------------------------------------
            String#+  3172217.8 (±4.6%) i/s -   15908402 in   5.026528s
       String#concat  3326443.4 (±3.9%) i/s -   16642935 in   5.011320s
       String#append  3482180.3 (±4.3%) i/s -   17423925 in   5.014100s
         "foo" "bar"  5727567.5 (±4.7%) i/s -   28697000 in   5.022824s

Comparison:
         "foo" "bar":  5727567.5 i/s
       String#append:  3482180.3 i/s - 1.64x slower
       String#concat:  3326443.4 i/s - 1.72x slower
            String#+:  3172217.8 i/s - 1.81x slower
```

##### `String#gsub` vs `String#sub` [code](code/string/gsub-vs-sub.rb)

```
$ ruby -v code/string/gsub-vs-sub.rb
ruby 2.2.0preview1 (2014-09-17 trunk 47616) [x86_64-darwin13]

Calculating -------------------------------------
         String#gsub     43991 i/100ms
          String#sub     52787 i/100ms
-------------------------------------------------
         String#gsub   584475.4 (±5.3%) i/s -    2947397 in   5.058064s
          String#sub   751518.3 (±4.2%) i/s -    3800664 in   5.066852s

Comparison:
          String#sub:   751518.3 i/s
         String#gsub:   584475.4 i/s - 1.29x slower
```

##### `String#gsub` vs `String#tr` [code](code/string/gsub-vs-tr.rb)

> [rails/rails#17257](https://github.com/rails/rails/pull/17257)

```
$ ruby -v code/string/gsub-vs-tr.rb
ruby 2.2.0preview1 (2014-09-17 trunk 47616) [x86_64-darwin13]

Calculating -------------------------------------
         String#gsub     45306 i/100ms
           String#tr     94363 i/100ms
-------------------------------------------------
         String#gsub   603615.0 (±3.9%) i/s -    3035502 in   5.036649s
           String#tr  2134064.7 (±3.2%) i/s -   10663019 in   5.002019s

Comparison:
           String#tr:  2134064.7 i/s
         String#gsub:   603615.0 i/s - 3.54x slower
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
ruby 2.2.0preview1 (2014-09-17 trunk 47616) [x86_64-darwin13]

Calculating -------------------------------------
           String#=~     50281 i/100ms
  String#start_with?    106594 i/100ms
-------------------------------------------------
           String#=~  1007225.5 (±30.3%) i/s -    4374447 in   5.006442s
  String#start_with?  4088874.6 (±10.5%) i/s -   20252860 in   5.014760s

Comparison:
  String#start_with?:  4088874.6 i/s
           String#=~:  1007225.5 i/s - 4.06x slower
```

```
$ ruby -v code/string/end-string-checking-match-vs-start_with.rb
ruby 2.2.0preview1 (2014-09-17 trunk 47616) [x86_64-darwin13]

Calculating -------------------------------------
           String#=~     43826 i/100ms
    String#end_with?     84810 i/100ms
-------------------------------------------------
           String#=~   926098.8 (±28.3%) i/s -    4075818 in   5.025425s
    String#end_with?  2792475.3 (±12.5%) i/s -   13739220 in   5.004958s

Comparison:
    String#end_with?:  2792475.3 i/s
           String#=~:   926098.8 i/s - 3.02x slower
```


##### `String#casecmp` vs `String#downcase + ==` [code](code/string/casecmp-vs-downcase-==.rb)

```
$ ruby -v code/string/casecmp-vs-downcase-\=\=.rb
ruby 2.2.0preview1 (2014-09-17 trunk 47616) [x86_64-darwin13]

Calculating -------------------------------------
String#downcase + ==    112715 i/100ms
      String#casecmp    121906 i/100ms
-------------------------------------------------
String#downcase + ==  3348751.8 (±5.2%) i/s -   16794535 in   5.029945s
      String#casecmp  4214478.7 (±4.7%) i/s -   21089738 in   5.016033s

Comparison:
      String#casecmp:  4214478.7 i/s
String#downcase + ==:  3348751.8 i/s - 1.26x slower
```

### Array

##### `Array#shuffle.first` vs `Array#sample` [code](code/array/shuffle-first-vs-sample.rb)

> `Array#shuffle` allocates an extra array. <br>
> `Array#sample` indexes into the array without allocating an extra array. <br>
> This is the reason why Array#sample exists. <br>
> —— @sferik [rails/rails#17245](https://github.com/rails/rails/pull/17245)

```
$ ruby -v code/array/shuffle-first-vs-sample.rb
ruby 2.2.0preview1 (2014-09-17 trunk 47616) [x86_64-darwin13]

Calculating -------------------------------------
 Array#shuffle.first     29000 i/100ms
        Array#sample    121248 i/100ms
-------------------------------------------------
 Array#shuffle.first   347632.6 (±8.0%) i/s -    1740000 in   5.041768s
        Array#sample  6155292.3 (±6.6%) i/s -   30675744 in   5.008394s

Comparison:
        Array#sample:  6155292.3 i/s
 Array#shuffle.first:   347632.6 i/s - 17.71x slower
```


### Enumerable

##### `Enumerable#map`...`Array#flatten` vs `Enumerable#flat_map` [code](code/enumerable/map-flatten-vs-flat_map.rb)

> -- @sferik [rails/rails@3413b88](https://github.com/rails/rails/commit/3413b88), [Replace map.flatten with flat_map](https://github.com/rails/rails/commit/817fe31196dd59ee31f71ef1740122b6759cf16d), [Replace map.flatten(1) with flat_map](https://github.com/rails/rails/commit/b11ebf1d80e4fb124f0ce0448cea30988256da59)

```
$ ruby -v code/enumerable/map-flatten-vs-flat_map.rb
ruby 2.2.0preview1 (2014-09-17 trunk 47616) [i686-linux]
Calculating -------------------------------------
Array#map.flatten(1)      1779 i/100ms
   Array#map.flatten      1793 i/100ms
      Array#flat_map      3298 i/100ms
-------------------------------------------------
Array#map.flatten(1)    18348.4 (±4.4%) i/s -      92508 in   5.053578s
   Array#map.flatten    17989.4 (±3.7%) i/s -      91443 in   5.090778s
      Array#flat_map    33926.1 (±11.0%) i/s -     168198 in   5.045198s

Comparison:
      Array#flat_map:    33926.1 i/s
Array#map.flatten(1):    18348.4 i/s - 1.85x slower
   Array#map.flatten:    17989.4 i/s - 1.89x slower
```

##### `Enumerable#reverse.each` vs `Enumerable#reverse_each` [code](code/enumerable/reverse-each-vs-reverse_each.rb)

> `Enumerable#reverse` allocates an extra array.  <br>
> `Enumerable#reverse_each` yields each value without allocating an extra array. <br>
> This is the reason why `Enumerable#reverse_each` exists. <br>
> -- @sferik [rails/rails#17244](https://github.com/rails/rails/pull/17244)

```
$ ruby -v code/enumerable/reverse-each-vs-reverse_each.rb
ruby 2.2.0preview1 (2014-09-17 trunk 47616) [x86_64-darwin13]

Calculating -------------------------------------
  Array#reverse.each     18475 i/100ms
  Array#reverse_each     20324 i/100ms
-------------------------------------------------
  Array#reverse.each   205046.1 (±4.0%) i/s -    1034600 in   5.054304s
  Array#reverse_each   231763.2 (±2.3%) i/s -    1178792 in   5.088863s

Comparison:
  Array#reverse_each:   231763.2 i/s
  Array#reverse.each:   205046.1 i/s - 1.13x slower
```

##### `Enumerable#each` vs `Enumerable#map + push` [code](code/enumerable/each-push-vs-map.rb)

```
$ ruby -v code/enumerable/each-push-vs-map.rb
ruby 2.2.0preview1 (2014-09-17 trunk 47616) [x86_64-darwin13]

Calculating -------------------------------------
   Array#each + push     10308 i/100ms
           Array#map     15125 i/100ms
-------------------------------------------------
   Array#each + push   106052.2 (±4.2%) i/s -     536016 in   5.063496s
           Array#map   166484.6 (±4.9%) i/s -     847000 in   5.100707s

Comparison:
           Array#map:   166484.6 i/s
   Array#each + push:   106052.2 i/s - 1.57x slower
```

##### `Enumerable#each_with_index` vs `while` loop [code](code/array/each_with_index-vs-while-loop.rb)

> [rails/rails#12065](https://github.com/rails/rails/pull/12065)

```
$ ruby -v code/array/each_with_index-vs-while-loop.rb
ruby 2.2.0preview1 (2014-09-17 trunk 47616) [x86_64-darwin13]

Calculating -------------------------------------
     each_with_index     13880 i/100ms
          While Loop     23616 i/100ms
-------------------------------------------------
     each_with_index   146266.8 (±2.7%) i/s -     735640 in   5.033031s
          While Loop   274998.8 (±3.0%) i/s -    1393344 in   5.071824s

Comparison:
          While Loop:   274998.8 i/s
     each_with_index:   146266.8 i/s - 1.88x slower
```

##### `Enumerable#sort` vs `Enumerable#sort_by` [code](code/enumerable/sort-vs-sort_by.rb)

```
$ ruby -v code/enumerable/sort-vs-sort_by.rb
ruby 2.2.0preview1 (2014-09-17 trunk 47616) [x86_64-darwin13]

Calculating -------------------------------------
     Enumerable#sort      1266 i/100ms
  Enumerable#sort_by      2688 i/100ms
-------------------------------------------------
     Enumerable#sort    12892.0 (±2.8%) i/s -      64566 in   5.012285s
  Enumerable#sort_by    27421.4 (±3.3%) i/s -     137088 in   5.004812s

Comparison:
  Enumerable#sort_by:    27421.4 i/s
     Enumerable#sort:    12892.0 i/s - 2.13x slower
```

### Hash

##### `Hash#merge` vs `Hash#merge!` [code](code/hash/merge-vs-merge-bang.rb)

```
$ ruby -v code/hash/merge-vs-merge-bang.rb
ruby 2.2.0preview1 (2014-09-17 trunk 47616) [x86_64-darwin13]

Calculating -------------------------------------
          Hash#merge        51 i/100ms
         Hash#merge!      1141 i/100ms
-------------------------------------------------
          Hash#merge      496.7 (±7.2%) i/s -       2499 in   5.054120s
         Hash#merge!    11656.2 (±3.5%) i/s -      59332 in   5.096368s

Comparison:
         Hash#merge!:    11656.2 i/s
          Hash#merge:      496.7 i/s - 23.47x slower
```


##### `Hash#merge!` vs `Hash#[]=` [code](code/hash/merge-bang-vs-\[\]=.rb)

```
$ ruby -v code/hash/merge-bang-vs-\[\]=.rb
ruby 2.2.0preview1 (2014-09-17 trunk 47616) [x86_64-darwin13]

Calculating -------------------------------------
         Hash#merge!      1276 i/100ms
            Hash#[]=      3303 i/100ms
-------------------------------------------------
         Hash#merge!    12913.5 (±3.6%) i/s -      65076 in   5.046038s
            Hash#[]=    34812.0 (±11.2%) i/s -     175059 in   5.079305s

Comparison:
            Hash#[]=:    34812.0 i/s
         Hash#merge!:    12913.5 i/s - 2.70x slower
```

##### `Hash#fetch` with argument vs `Hash#fetch` + block [code](code/hash/fetch-vs-fetch-with-block.rb)

```
$ ruby -v code/hash/fetch-vs-fetch-with-block.rb
ruby 2.2.0preview1 (2014-09-17 trunk 47616) [x86_64-darwin13]

Calculating -------------------------------------
    Hash#fetch + arg     19954 i/100ms
  Hash#fetch + block    146532 i/100ms
-------------------------------------------------
    Hash#fetch + arg   230612.5 (±3.8%) i/s -    1157332 in   5.026216s
  Hash#fetch + block  6496408.6 (±3.5%) i/s -   32530104 in   5.014893s

Comparison:
  Hash#fetch + block:  6496408.6 i/s
    Hash#fetch + arg:   230612.5 i/s - 28.17x slower
```

##### `Hash#each_key` instead of `Hash#keys.each` [code](code/hash/keys-each-vs-each_key.rb)

> `Hash#keys.each` allocates an array of keys;  <br>
> `Hash#each_key` iterates through the keys without allocating a new array.  <br>
> This is the reason why `Hash#each_key` exists.  <br>
> —— @sferik [rails/rails#17099](https://github.com/rails/rails/pull/17099)

```
$ ruby -v code/hash/keys-each-vs-each_key.rb
ruby 2.2.0preview1 (2014-09-17 trunk 47616) [x86_64-darwin13]

Calculating -------------------------------------
      Hash#keys.each     66419 i/100ms
       Hash#each_key     73281 i/100ms
-------------------------------------------------
      Hash#keys.each  1031745.2 (±3.9%) i/s -    5180682 in   5.029275s
       Hash#each_key  1215805.3 (±3.5%) i/s -    6082323 in   5.009353s

Comparison:
       Hash#each_key:  1215805.3 i/s
      Hash#keys.each:  1031745.2 i/s - 1.18x slower
```

### Proc & Block

##### `Proc#call` vs `yield` [code](code/proc-and-block/proc-call-vs-yield.rb)

```
$ ruby -v code/proc-and-block/proc-call-vs-yield.rb
ruby 2.2.0preview1 (2014-09-17 trunk 47616) [x86_64-darwin13]

Calculating -------------------------------------
          block.call     84982 i/100ms
               yield    149488 i/100ms
-------------------------------------------------
          block.call  1584410.0 (±4.3%) i/s -    7988308 in   5.051477s
               yield  6544207.5 (±5.5%) i/s -   32737872 in   5.019144s

Comparison:
               yield:  6544207.5 i/s
          block.call:  1584410.0 i/s - 4.13x slower
```

##### Block vs `Symbol#to_proc` [code](code/proc-and-block/block-vs-to_proc.rb)

> `Symbol#to_proc` is considerably more concise than using block syntax. <br>
> ...In some cases, it reduces the number of lines of code. <br>
> —— @sferik [rails/rails#16833](https://github.com/rails/rails/pull/16833)

```
$ ruby -v code/proc-and-block/block-vs-to_proc.rb
ruby 2.2.0preview1 (2014-09-17 trunk 47616) [x86_64-darwin13]

Calculating -------------------------------------
               Block      5609 i/100ms
      Symbol#to_proc      6599 i/100ms
-------------------------------------------------
               Block    55716.2 (±6.8%) i/s -     280450 in   5.059515s
      Symbol#to_proc    67124.3 (±6.6%) i/s -     336549 in   5.038400s

Comparison:
      Symbol#to_proc:    67124.3 i/s
               Block:    55716.2 i/s - 1.20x slower
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

## License

![CC-BY-SA](CC-BY-SA.png)

This work is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-sa/4.0/).
