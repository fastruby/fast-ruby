Fast Ruby [![Benchmarks](https://github.com/fastruby/fast-ruby/actions/workflows/benchmarks.yml/badge.svg)](https://github.com/fastruby/fast-ruby/actions/workflows/benchmarks.yml)
=======================================================================================================================================================================

In [Erik Michaels-Ober](https://github.com/sferik)'s great talk, 'Writing Fast Ruby': [Video @ Baruco 2014](https://www.youtube.com/watch?v=fGFM_UrSp70), [Slide](https://speakerdeck.com/sferik/writing-fast-ruby), he presented us with many idioms that lead to faster running Ruby code. He inspired me to document these to let more people know. I try to link to real commits so people can see that this can really have benefits in the real world. **This does not mean you can always blindly replace one with another. It depends on the context (e.g. `gsub` versus `tr`). Friendly reminder: Use with caution!**

Each idiom has a corresponding code example that resides in [code](code).

All results listed in README.md are running with Ruby 4.0.0 on macOS 15.6.1. Machine information: MacBook Pro (14-inch, Nov 2024), Apple M4 Pro, 48 GB RAM. Your results may vary, but you get the idea. : )

You can checkout [the GitHub Actions build](https://github.com/fastruby/fast-ruby/actions) for these benchmark results ran against different Ruby implementations.

**Let's write faster code, together! <3**

Analyze your code
-----------------

Checkout the [fasterer](https://github.com/DamirSvrtan/fasterer) project - it's a static analysis that checks speed idioms written in this repo.

Measurement Tool
-----------------

Use [benchmark-ips](https://github.com/evanphx/benchmark-ips) (2.0+).

### Template

```ruby
require "benchmark/ips"

def fast
end

def slow
end

Benchmark.ips do |x|
  x.report("fast code description") { fast }
  x.report("slow code description") { slow }
  x.compare!
end
```

Idioms
------

### Index

- [General](#general)
- [Array](#array)
- [BigDecimal](#bigdecimal)
- [Date](#date)
- [Enumerable](#enumerable)
- [Hash](#hash)
- [Proc & Block](#proc--block)
- [String](#string)
- [Time](#time)
- [Range](#range)

### General

##### `attr_accessor` vs `getter and setter` [code](code/general/attr-accessor-vs-getter-and-setter.rb)

> https://www.omniref.com/ruby/2.2.0/files/method.h?#annotation=4081781&line=47

```
$ ruby -v code/general/attr-accessor-vs-getter-and-setter.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
   getter_and_setter     1.122M i/100ms
       attr_accessor     1.303M i/100ms
Calculating -------------------------------------
   getter_and_setter     10.999M (± 2.1%) i/s   (90.92 ns/i) -     56.083M in   5.101077s
       attr_accessor     12.517M (± 1.5%) i/s   (79.89 ns/i) -     63.841M in   5.101477s

Comparison:
       attr_accessor: 12517008.0 i/s
   getter_and_setter: 10999275.5 i/s - 1.14x  slower
```

##### `begin...rescue` vs `respond_to?` for Control Flow [code](code/general/begin-rescue-vs-respond-to.rb)

```
$ ruby -v code/general/begin-rescue-vs-respond-to.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
      begin...rescue   230.601k i/100ms
         respond_to?     1.915M i/100ms
Calculating -------------------------------------
      begin...rescue      2.390M (± 0.9%) i/s  (418.40 ns/i) -     11.991M in   5.017466s
         respond_to?     18.745M (± 1.8%) i/s   (53.35 ns/i) -     93.843M in   5.007990s

Comparison:
         respond_to?: 18744998.8 i/s
      begin...rescue:  2390076.1 i/s - 7.84x  slower
```

##### `define_method` vs `module_eval` for Defining Methods [code](code/general/define_method-vs-module-eval.rb)

```
$ ruby -v code/general/define_method-vs-module-eval.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
module_eval with string
                       630.000 i/100ms
       define_method   685.000 i/100ms
Calculating -------------------------------------
module_eval with string
                          5.633k (±18.1%) i/s  (177.53 μs/i) -     27.090k in   5.009884s
       define_method      7.239k (±17.6%) i/s  (138.14 μs/i) -     34.250k in   5.040522s

Comparison:
       define_method:     7238.9 i/s
module_eval with string:     5632.8 i/s - same-ish: difference falls within error
```

##### `String#constantize` vs a comparison for inflection [code](code/general/constantize-vs-comparison.rb)

ActiveSupport's [String#constantize](https://guides.rubyonrails.org/active_support_core_extensions.html#constantize) "resolves the constant reference expression in its receiver".

[Read the rationale here](https://github.com/fastruby/fast-ruby/pull/200)

```
$ ruby -v code/general/constantize-vs-comparison.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
using an if statement
                         1.507M i/100ms
  String#constantize     1.048M i/100ms
Calculating -------------------------------------
using an if statement
                         15.518M (± 1.2%) i/s   (64.44 ns/i) -     78.355M in   5.050041s
  String#constantize     10.556M (± 1.0%) i/s   (94.73 ns/i) -     53.448M in   5.063570s

Comparison:
using an if statement: 15517955.2 i/s
  String#constantize: 10556362.4 i/s - 1.47x  slower
```

##### `raise` vs `E2MM#Raise` for raising (and defining) exceptions  [code](code/general/raise-vs-e2mmap.rb)

Ruby's [Exception2MessageMapper module](http://ruby-doc.org/stdlib-2.2.0/libdoc/e2mmap/rdoc/index.html) allows one to define and raise exceptions with predefined messages.

```
$ ruby -v code/general/raise-vs-e2mmap.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
Ruby exception: E2MM#Raise
                         8.751k i/100ms
Ruby exception: Kernel#raise
                       254.268k i/100ms
Calculating -------------------------------------
Ruby exception: E2MM#Raise
                         88.269k (± 0.5%) i/s   (11.33 μs/i) -    446.301k in   5.056287s
Ruby exception: Kernel#raise
                          2.571M (± 1.0%) i/s  (389.01 ns/i) -     12.968M in   5.044976s

Comparison:
Ruby exception: Kernel#raise:  2570660.6 i/s
Ruby exception: E2MM#Raise:    88268.9 i/s - 29.12x  slower

ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
Custom exception: E2MM#Raise
                         8.837k i/100ms
Custom exception: Kernel#raise
                       263.896k i/100ms
Calculating -------------------------------------
Custom exception: E2MM#Raise
                         88.322k (± 0.6%) i/s   (11.32 μs/i) -    441.850k in   5.002885s
Custom exception: Kernel#raise
                          2.599M (± 2.1%) i/s  (384.78 ns/i) -     13.195M in   5.079300s

Comparison:
Custom exception: Kernel#raise:  2598894.6 i/s
Custom exception: E2MM#Raise:    88322.1 i/s - 29.43x  slower
```

##### `loop` vs `while true` [code](code/general/loop-vs-while-true.rb)

```
$ ruby -v code/general/loop-vs-while-true.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
          While Loop     1.000 i/100ms
         Kernel loop     1.000 i/100ms
Calculating -------------------------------------
          While Loop      1.331 (± 0.0%) i/s  (751.41 ms/i) -      7.000 in   5.260296s
         Kernel loop      0.528 (± 0.0%) i/s     (1.89 s/i) -      3.000 in   5.709880s

Comparison:
          While Loop:        1.3 i/s
         Kernel loop:        0.5 i/s - 2.52x  slower
```

##### `ancestors.include?` vs `<=` [code](code/general/inheritance-check.rb)

```
$ ruby -v code/general/inheritance-check.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
  less than or equal     1.150M i/100ms
  ancestors.include?   179.611k i/100ms
Calculating -------------------------------------
  less than or equal     11.426M (± 1.4%) i/s   (87.52 ns/i) -     57.493M in   5.032894s
  ancestors.include?      1.880M (± 1.0%) i/s  (531.84 ns/i) -      9.519M in   5.063302s

Comparison:
  less than or equal: 11425608.6 i/s
  ancestors.include?:  1880262.8 i/s - 6.08x  slower
```

### Method Invocation

##### `call` vs `send` vs `method_missing` [code](code/method/call-vs-send-vs-method_missing.rb)

```
$ ruby -v code/method/call-vs-send-vs-method_missing.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
                call     1.670M i/100ms
                send     1.182M i/100ms
      method_missing   837.965k i/100ms
Calculating -------------------------------------
                call     16.799M (± 0.3%) i/s   (59.53 ns/i) -     85.150M in   5.068737s
                send     11.845M (± 0.3%) i/s   (84.42 ns/i) -     60.281M in   5.089071s
      method_missing      8.392M (± 0.3%) i/s  (119.17 ns/i) -     42.736M in   5.092719s

Comparison:
                call: 16799285.6 i/s
                send: 11845293.0 i/s - 1.42x  slower
      method_missing:  8391692.6 i/s - 2.00x  slower
```

##### Normal way to apply method vs `&method(...)` [code](code/general/block-apply-method.rb)

```
$ ruby -v code/general/block-apply-method.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
              normal   698.536k i/100ms
             &method   322.901k i/100ms
Calculating -------------------------------------
              normal      6.978M (± 0.9%) i/s  (143.31 ns/i) -     34.927M in   5.005888s
             &method      3.214M (± 0.5%) i/s  (311.12 ns/i) -     16.145M in   5.023139s

Comparison:
              normal:  6977718.6 i/s
             &method:  3214214.6 i/s - 2.17x  slower
```

##### Function with single Array argument vs splat arguments [code](code/general/array-argument-vs-splat-arguments.rb)

```
$ ruby -v code/general/array-argument-vs-splat-arguments.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
Function with single Array argument
                         1.910M i/100ms
Function with splat arguments
                        18.841k i/100ms
Calculating -------------------------------------
Function with single Array argument
                         18.818M (± 1.2%) i/s   (53.14 ns/i) -     95.479M in   5.074468s
Function with splat arguments
                        217.060k (±11.2%) i/s    (4.61 μs/i) -      1.093M in   5.099583s

Comparison:
Function with single Array argument: 18818207.9 i/s
Function with splat arguments:   217059.9 i/s - 86.70x  slower
```

##### Hash vs OpenStruct on access assuming you already have a Hash or an OpenStruct [code](code/general/hash-vs-openstruct-on-access.rb)

```
$ ruby -v code/general/hash-vs-openstruct-on-access.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
                Hash     2.028M i/100ms
          OpenStruct     1.478M i/100ms
Calculating -------------------------------------
                Hash     20.290M (± 0.5%) i/s   (49.29 ns/i) -    103.430M in   5.097815s
          OpenStruct     14.807M (± 0.6%) i/s   (67.54 ns/i) -     75.387M in   5.091599s

Comparison:
                Hash: 20289714.4 i/s
          OpenStruct: 14806564.8 i/s - 1.37x  slower
```

##### Hash vs OpenStruct (creation) [code](code/general/hash-vs-openstruct.rb)

```
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
                Hash     2.652M i/100ms
          OpenStruct    31.241k i/100ms
Calculating -------------------------------------
                Hash     26.301M (± 1.0%) i/s   (38.02 ns/i) -    132.614M in   5.042769s
          OpenStruct    313.539k (± 1.8%) i/s    (3.19 μs/i) -      1.593M in   5.083245s

Comparison:
                Hash: 26300561.3 i/s
          OpenStruct:   313538.7 i/s - 83.88x  slower
```

##### Kernel#format vs Float#round().to_s [code](code/general/format-vs-round-and-to-s.rb)

```
$ ruby -v code/general/format-vs-round-and-to-s.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
         Float#round   465.786k i/100ms
       Kernel#format   618.743k i/100ms
            String#%   562.895k i/100ms
Calculating -------------------------------------
         Float#round      4.780M (± 0.6%) i/s  (209.21 ns/i) -     24.221M in   5.067359s
       Kernel#format      6.200M (± 1.4%) i/s  (161.29 ns/i) -     31.556M in   5.090736s
            String#%      5.642M (± 1.1%) i/s  (177.25 ns/i) -     28.708M in   5.088913s

Comparison:
       Kernel#format:  6199975.0 i/s
            String#%:  5641863.3 i/s - 1.10x  slower
         Float#round:  4779984.9 i/s - 1.30x  slower
```

### Array

##### `Array#bsearch` vs `Array#find` [code](code/array/bsearch-vs-find.rb)

**WARNING:** `bsearch` ONLY works on *sorted array*. More details please see [#29](https://github.com/fastruby/fast-ruby/issues/29).

```
$ ruby -v code/array/bsearch-vs-find.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
                find     1.000 i/100ms
             bsearch   189.387k i/100ms
Calculating -------------------------------------
                find      0.703 (± 0.0%) i/s     (1.42 s/i) -      4.000 in   5.692110s
             bsearch      1.893M (± 1.6%) i/s  (528.21 ns/i) -      9.469M in   5.003152s

Comparison:
             bsearch:  1893194.5 i/s
                find:        0.7 i/s - 2691605.95x  slower
```

##### `Array#length` vs `Array#size` vs `Array#count` [code](code/array/length-vs-size-vs-count.rb)

Use `#length` when you only want to know how many elements in the array, `#count` could also achieve this. However `#count` should be use for counting specific elements in array. [Note `#size` is an alias of `#length`](https://github.com/ruby/ruby/blob/f8fb526ad9e9f31453bffbc908b6a986736e21a7/array.c#L5817-L5818).

```
$ ruby -v code/array/length-vs-size-vs-count.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
        Array#length     5.024M i/100ms
          Array#size     4.994M i/100ms
         Array#count     3.781M i/100ms
Calculating -------------------------------------
        Array#length     50.668M (± 0.8%) i/s   (19.74 ns/i) -    256.237M in   5.057495s
          Array#size     50.580M (± 0.7%) i/s   (19.77 ns/i) -    254.704M in   5.035880s
         Array#count     38.202M (± 0.8%) i/s   (26.18 ns/i) -    192.843M in   5.048306s

Comparison:
        Array#length: 50667869.8 i/s
          Array#size: 50580088.8 i/s - same-ish: difference falls within error
         Array#count: 38201768.5 i/s - 1.33x  slower
```

##### `Array#shuffle.first` vs `Array#sample` [code](code/array/shuffle-first-vs-sample.rb)

> `Array#shuffle` allocates an extra array. <br>
> `Array#sample` indexes into the array without allocating an extra array. <br>
> This is the reason why Array#sample exists. <br>
> —— @sferik [rails/rails#17245](https://github.com/rails/rails/pull/17245)

```
$ ruby -v code/array/shuffle-first-vs-sample.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
 Array#shuffle.first    88.991k i/100ms
        Array#sample     2.503M i/100ms
Calculating -------------------------------------
 Array#shuffle.first    891.780k (± 0.5%) i/s    (1.12 μs/i) -      4.539M in   5.089459s
        Array#sample     25.133M (± 0.6%) i/s   (39.79 ns/i) -    127.660M in   5.079516s

Comparison:
        Array#sample: 25133099.8 i/s
 Array#shuffle.first:   891779.8 i/s - 28.18x  slower
```

##### `Array#[](0)` vs `Array#first` [code](code/array/array-first-vs-index.rb)

```
$ ruby -v code/array/array-first-vs-index.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
           Array#[0]     3.922M i/100ms
         Array#first     3.697M i/100ms
Calculating -------------------------------------
           Array#[0]     39.347M (± 0.7%) i/s   (25.41 ns/i) -    200.006M in   5.083307s
         Array#first     37.289M (± 1.1%) i/s   (26.82 ns/i) -    188.546M in   5.056917s

Comparison:
           Array#[0]: 39347487.6 i/s
         Array#first: 37288935.3 i/s - 1.06x  slower
```

##### `Array#[](-1)` vs `Array#last` [code](code/array/array-last-vs-index.rb)

```
$ ruby -v code/array/array-last-vs-index.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
          Array#[-1]     3.906M i/100ms
          Array#last     3.727M i/100ms
Calculating -------------------------------------
          Array#[-1]     39.303M (± 0.7%) i/s   (25.44 ns/i) -    199.228M in   5.069210s
          Array#last     37.280M (± 1.1%) i/s   (26.82 ns/i) -    190.075M in   5.099254s

Comparison:
          Array#[-1]: 39303493.5 i/s
          Array#last: 37279563.5 i/s - 1.05x  slower
```

##### `Array#insert` vs `Array#unshift` [code](code/array/insert-vs-unshift.rb)

```
$ ruby -v code/array/insert-vs-unshift.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
       Array#unshift    37.000 i/100ms
        Array#insert     1.000 i/100ms
Calculating -------------------------------------
       Array#unshift    379.798 (± 1.1%) i/s    (2.63 ms/i) -      1.924k in   5.066300s
        Array#insert      1.717 (± 0.0%) i/s  (582.49 ms/i) -      9.000 in   5.242429s

Comparison:
       Array#unshift:      379.8 i/s
        Array#insert:        1.7 i/s - 221.23x  slower
```
##### `Array#concat` vs `Array#+` [code](code/array/array-concat-vs-+.rb)
`Array#+` returns a new array built by concatenating the two arrays together to
produce a third array. `Array#concat` appends the elements of the other array to self.
This means that the + operator will create a new array each time it is called
(which is expensive), while concat only appends the new element.
```
$ ruby -v code/array/array-concat-vs-+.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
        Array#concat   126.000 i/100ms
             Array#+     1.000 i/100ms
Calculating -------------------------------------
        Array#concat      1.259k (± 1.1%) i/s  (793.98 μs/i) -      6.300k in   5.002769s
             Array#+      5.170 (± 0.0%) i/s  (193.42 ms/i) -     26.000 in   5.033770s

Comparison:
        Array#concat:     1259.5 i/s
             Array#+:        5.2 i/s - 243.60x  slower
```

##### `Array#new` vs `Fixnum#times + map` [code](code/array/array-new-vs-fixnum-times-map.rb)

Typical slowdown is 40-60% depending on the size of the array. See the corresponding
[pull request](https://github.com/fastruby/fast-ruby/pull/91/) for performance characteristics.

```
$ ruby -v code/array/array-new-vs-fixnum-times-map.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
           Array#new   424.914k i/100ms
  Fixnum#times + map   187.997k i/100ms
Calculating -------------------------------------
           Array#new      4.251M (± 0.4%) i/s  (235.25 ns/i) -     21.671M in   5.098122s
  Fixnum#times + map      1.886M (± 0.4%) i/s  (530.31 ns/i) -      9.588M in   5.084632s

Comparison:
           Array#new:  4250785.8 i/s
  Fixnum#times + map:  1885679.9 i/s - 2.25x  slower
```

##### `Array#sort.reverse` vs `Array#sort_by` +  block [code](code/array/sort-reverse-vs-sort_by-with-block.rb)

```
$ ruby -v code/array/sort-reverse-vs-sort_by-with-block.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
  Array#sort.reverse    55.279k i/100ms
  Array#sort_by &:-@    22.773k i/100ms
Calculating -------------------------------------
  Array#sort.reverse    560.570k (± 0.9%) i/s    (1.78 μs/i) -      2.819M in   5.029648s
  Array#sort_by &:-@    229.324k (± 0.6%) i/s    (4.36 μs/i) -      1.161M in   5.064717s

Comparison:
  Array#sort.reverse:   560570.1 i/s
  Array#sort_by &:-@:   229323.6 i/s - 2.44x  slower
```

### Enumerable

##### `Enumerable#each + push` vs `Enumerable#map` [code](code/enumerable/each-push-vs-map.rb)

```
$ ruby -v code/enumerable/each-push-vs-map.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
   Array#each + push    31.310k i/100ms
           Array#map    51.371k i/100ms
Calculating -------------------------------------
   Array#each + push    320.334k (± 0.6%) i/s    (3.12 μs/i) -      1.628M in   5.082743s
           Array#map    511.854k (± 1.3%) i/s    (1.95 μs/i) -      2.569M in   5.019061s

Comparison:
           Array#map:   511854.5 i/s
   Array#each + push:   320334.1 i/s - 1.60x  slower
```

##### `Enumerable#each` vs `for` loop [code](code/enumerable/each-vs-for-loop.rb)

```
$ ruby -v code/enumerable/each-vs-for-loop.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
            For loop    54.498k i/100ms
               #each    63.984k i/100ms
Calculating -------------------------------------
            For loop    525.548k (± 8.8%) i/s    (1.90 μs/i) -      2.670M in   5.128917s
               #each    641.789k (± 0.3%) i/s    (1.56 μs/i) -      3.263M in   5.084548s

Comparison:
               #each:   641788.6 i/s
            For loop:   525547.8 i/s - 1.22x  slower
```

##### `Enumerable#each_with_index` vs `while` loop [code](code/enumerable/each_with_index-vs-while-loop.rb)

> [rails/rails#12065](https://github.com/rails/rails/pull/12065)

```
$ ruby -v code/enumerable/each_with_index-vs-while-loop.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
          While Loop    49.050k i/100ms
     each_with_index    36.684k i/100ms
Calculating -------------------------------------
          While Loop    501.430k (± 2.9%) i/s    (1.99 μs/i) -      2.551M in   5.091049s
     each_with_index    369.364k (± 0.3%) i/s    (2.71 μs/i) -      1.871M in   5.065187s

Comparison:
          While Loop:   501430.2 i/s
     each_with_index:   369364.5 i/s - 1.36x  slower
```

##### `Enumerable#map`...`Array#flatten` vs `Enumerable#flat_map` [code](code/enumerable/map-flatten-vs-flat_map.rb)

> -- @sferik [rails/rails@3413b88](https://github.com/rails/rails/commit/3413b88), [Replace map.flatten with flat_map](https://github.com/rails/rails/commit/817fe31196dd59ee31f71ef1740122b6759cf16d), [Replace map.flatten(1) with flat_map](https://github.com/rails/rails/commit/b11ebf1d80e4fb124f0ce0448cea30988256da59)

```
$ ruby -v code/enumerable/map-flatten-vs-flat_map.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
Array#map.flatten(1)    19.072k i/100ms
   Array#map.flatten     8.810k i/100ms
      Array#flat_map    21.362k i/100ms
Calculating -------------------------------------
Array#map.flatten(1)    196.444k (± 1.2%) i/s    (5.09 μs/i) -    991.744k in   5.049225s
   Array#map.flatten     89.917k (± 1.2%) i/s   (11.12 μs/i) -    458.120k in   5.095661s
      Array#flat_map    215.149k (± 0.6%) i/s    (4.65 μs/i) -      1.089M in   5.063916s

Comparison:
      Array#flat_map:   215149.2 i/s
Array#map.flatten(1):   196443.8 i/s - 1.10x  slower
   Array#map.flatten:    89916.9 i/s - 2.39x  slower
```

##### `Enumerable#reverse.each` vs `Enumerable#reverse_each` [code](code/enumerable/reverse-each-vs-reverse_each.rb)

> `Enumerable#reverse` allocates an extra array.  <br>
> `Enumerable#reverse_each` yields each value without allocating an extra array. <br>
> This is the reason why `Enumerable#reverse_each` exists. <br>
> -- @sferik [rails/rails#17244](https://github.com/rails/rails/pull/17244)

```
$ ruby -v code/enumerable/reverse-each-vs-reverse_each.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
  Array#reverse.each    58.610k i/100ms
  Array#reverse_each    63.669k i/100ms
Calculating -------------------------------------
  Array#reverse.each    586.309k (± 0.7%) i/s    (1.71 μs/i) -      2.989M in   5.098469s
  Array#reverse_each    635.904k (± 2.3%) i/s    (1.57 μs/i) -      3.183M in   5.009371s

Comparison:
  Array#reverse_each:   635904.1 i/s
  Array#reverse.each:   586309.0 i/s - 1.08x  slower
```

##### `Enumerable#sort_by.first` vs `Enumerable#min_by` [code](code/enumerable/sort_by-first-vs-min_by.rb)
`Enumerable#sort_by` performs a sort of the enumerable and allocates a
new array the size of the enumerable.  `Enumerable#min_by` doesn't
perform a sort or allocate an array the size of the enumerable.
Similar comparisons hold for `Enumerable#sort_by.last` vs
`Enumerable#max_by`, `Enumerable#sort.first` vs `Enumerable#min`, and
`Enumerable#sort.last` vs `Enumerable#max`.

```
$ ruby -v code/enumerable/sort_by-first-vs-min_by.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
   Enumerable#min_by    40.784k i/100ms
Enumerable#sort_by...first
                        32.912k i/100ms
Calculating -------------------------------------
   Enumerable#min_by    408.114k (± 0.3%) i/s    (2.45 μs/i) -      2.080M in   5.096613s
Enumerable#sort_by...first
                        334.401k (± 0.7%) i/s    (2.99 μs/i) -      1.679M in   5.019698s

Comparison:
   Enumerable#min_by:   408113.9 i/s
Enumerable#sort_by...first:   334400.9 i/s - 1.22x  slower
```

##### `Enumerable#detect` vs `Enumerable#select.first` [code](code/enumerable/select-first-vs-detect.rb)

```
$ ruby -v code/enumerable/select-first-vs-detect.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
Enumerable#select.first
                        37.402k i/100ms
   Enumerable#detect   247.638k i/100ms
Calculating -------------------------------------
Enumerable#select.first
                        373.115k (± 0.6%) i/s    (2.68 μs/i) -      7.480M in  20.049160s
   Enumerable#detect      2.462M (± 0.8%) i/s  (406.12 ns/i) -     49.280M in  20.014730s

Comparison:
   Enumerable#detect:  2462330.2 i/s
Enumerable#select.first:   373115.1 i/s - 6.60x  slower
```

##### `Enumerable#select.last` vs `Enumerable#reverse.detect` [code](code/enumerable/select-last-vs-reverse-detect.rb)

```
$ ruby -v code/enumerable/select-last-vs-reverse-detect.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
Enumerable#reverse.detect
                        23.133k i/100ms
Enumerable#select.last
                       562.000 i/100ms
Calculating -------------------------------------
Enumerable#reverse.detect
                        241.463k (± 5.5%) i/s    (4.14 μs/i) -      1.226M in   5.092374s
Enumerable#select.last
                          5.640k (± 0.9%) i/s  (177.30 μs/i) -     28.662k in   5.082075s

Comparison:
Enumerable#reverse.detect:   241463.1 i/s
Enumerable#select.last:     5640.3 i/s - 42.81x  slower
```

##### `Enumerable#sort` vs `Enumerable#sort_by` [code](code/enumerable/sort-vs-sort_by.rb)

```
$ ruby -v code/enumerable/sort-vs-sort_by.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
Enumerable#sort_by (Symbol#to_proc)
                        16.077k i/100ms
  Enumerable#sort_by    15.265k i/100ms
     Enumerable#sort     4.580k i/100ms
Calculating -------------------------------------
Enumerable#sort_by (Symbol#to_proc)
                        162.709k (± 0.9%) i/s    (6.15 μs/i) -    819.927k in   5.039602s
  Enumerable#sort_by    152.611k (± 0.7%) i/s    (6.55 μs/i) -    763.250k in   5.001512s
     Enumerable#sort     45.814k (± 1.4%) i/s   (21.83 μs/i) -    233.580k in   5.099352s

Comparison:
Enumerable#sort_by (Symbol#to_proc):   162709.4 i/s
  Enumerable#sort_by:   152611.3 i/s - 1.07x  slower
     Enumerable#sort:    45814.3 i/s - 3.55x  slower
```

##### `Enumerable#inject Symbol` vs `Enumerable#inject Proc` [code](code/enumerable/inject-symbol-vs-block.rb)

Of note, `to_proc` for 1.8.7 is considerable slower than the block format

```
$ ruby -v code/enumerable/inject-symbol-vs-block.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
       inject symbol   183.846k i/100ms
      inject to_proc     4.100k i/100ms
        inject block     3.882k i/100ms
Calculating -------------------------------------
       inject symbol      1.841M (± 0.4%) i/s  (543.31 ns/i) -      9.376M in   5.094226s
      inject to_proc     41.165k (± 0.3%) i/s   (24.29 μs/i) -    209.100k in   5.079636s
        inject block     39.550k (± 0.6%) i/s   (25.28 μs/i) -    197.982k in   5.006073s

Comparison:
       inject symbol:  1840578.1 i/s
      inject to_proc:    41164.7 i/s - 44.71x  slower
        inject block:    39550.0 i/s - 46.54x  slower
```

### BigDecimal

##### `BigDecimal('1')` vs `BigDecimal('1.0')` vs `'1'.to_d` vs `'1.0'.to_d` vs `BigDecimal(1)` vs `1.to_d` vs `BigDecimal(1.0, 2)` vs `1.0.to_d` [code](code/bigdecimal/string-vs-numeric.rb)

```
$ ruby -v code/bigdecimal/string-vs-numeric.rb
ruby 2.5.3p105 (2018-10-18 revision 65156) [x86_64-darwin18]
Calculating -------------------------------------
  integer string new      2.497M (± 2.0%) i/s -     12.645M in   5.066385s
    float string new      2.414M (± 2.0%) i/s -     12.182M in   5.048473s
 integer string to_d      2.402M (± 1.8%) i/s -     12.010M in   5.001784s
   float string to_d      2.318M (± 1.8%) i/s -     11.663M in   5.032429s
         integer new      1.601M (± 1.2%) i/s -      8.022M in   5.010201s
        integer to_d      1.563M (± 1.8%) i/s -      7.817M in   5.001726s
           float new    517.635k (± 4.5%) i/s -      2.604M in   5.042605s
          float to_d    529.413k (± 3.6%) i/s -      2.671M in   5.051477s

Comparison:
  integer string new:  2496860.3 i/s
    float string new:  2414122.8 i/s - same-ish: difference falls within error
 integer string to_d:  2401929.3 i/s - 1.04x  slower
   float string to_d:  2318272.7 i/s - 1.08x  slower
         integer new:  1601402.4 i/s - 1.56x  slower
        integer to_d:  1563335.6 i/s - 1.60x  slower
          float to_d:   529412.7 i/s - 4.72x  slower
           float new:   517634.5 i/s - 4.82x  slower
```

### Date

##### `Date.iso8601` vs `Date.parse` [code](code/date/iso8601-vs-parse.rb)

When expecting well-formatted data from e.g. an API, `iso8601` is faster and will raise an `ArgumentError` on malformed input.

```
$ ruby -v code/date/iso8601-vs-parse.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
        Date.iso8601   195.684k i/100ms
          Date.parse    62.633k i/100ms
Calculating -------------------------------------
        Date.iso8601      2.008M (± 0.8%) i/s  (497.99 ns/i) -     10.176M in   5.067673s
          Date.parse    627.349k (± 0.7%) i/s    (1.59 μs/i) -      3.194M in   5.092000s

Comparison:
        Date.iso8601:  2008075.4 i/s
          Date.parse:   627349.2 i/s - 3.20x  slower
```

### Hash

##### `Hash#[]` vs `Hash#fetch` [code](code/hash/bracket-vs-fetch.rb)

If you use Ruby 2.2, `Symbol` could be more performant than `String` as `Hash` keys.
Read more regarding this: [Symbol GC in Ruby 2.2](http://www.sitepoint.com/symbol-gc-ruby-2-2/) and [Unraveling String Key Performance in Ruby 2.2](http://www.sitepoint.com/unraveling-string-key-performance-ruby-2-2/).

```
$ ruby -v code/hash/bracket-vs-fetch.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
     Hash#[], symbol     3.471M i/100ms
  Hash#fetch, symbol     2.869M i/100ms
     Hash#[], string     1.969M i/100ms
  Hash#fetch, string     1.746M i/100ms
Calculating -------------------------------------
     Hash#[], symbol     34.983M (± 0.8%) i/s   (28.59 ns/i) -    177.026M in   5.060743s
  Hash#fetch, symbol     28.927M (± 1.1%) i/s   (34.57 ns/i) -    146.331M in   5.059120s
     Hash#[], string     19.711M (± 1.7%) i/s   (50.73 ns/i) -    100.431M in   5.096713s
  Hash#fetch, string     17.825M (± 1.4%) i/s   (56.10 ns/i) -     90.775M in   5.093555s

Comparison:
     Hash#[], symbol: 34982573.5 i/s
  Hash#fetch, symbol: 28927450.2 i/s - 1.21x  slower
     Hash#[], string: 19710678.7 i/s - 1.77x  slower
  Hash#fetch, string: 17825222.3 i/s - 1.96x  slower
```

##### `Hash#dig` vs `Hash#[]` vs `Hash#fetch` [code](code/hash/dig-vs-[]-vs-fetch.rb)

[Ruby 2.3 introduced `Hash#dig`](http://ruby-doc.org/core-2.3.0/Hash.html#method-i-dig) which is a readable
and performant option for retrieval from a nested hash, returning `nil` if an extraction step fails.
See [#102 (comment)](https://github.com/fastruby/fast-ruby/pull/102#issuecomment-198827506) for more info.

```
$ ruby -v code/hash/dig-vs-[]-vs-fetch.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
            Hash#dig     1.939M i/100ms
             Hash#[]     1.903M i/100ms
          Hash#[] ||     1.787M i/100ms
          Hash#[] &&   725.944k i/100ms
          Hash#fetch     1.246M i/100ms
 Hash#fetch fallback   803.269k i/100ms
Calculating -------------------------------------
            Hash#dig     19.434M (± 0.8%) i/s   (51.46 ns/i) -     98.877M in   5.088095s
             Hash#[]     19.005M (± 2.2%) i/s   (52.62 ns/i) -     95.141M in   5.008511s
          Hash#[] ||     17.879M (± 0.7%) i/s   (55.93 ns/i) -     91.138M in   5.097648s
          Hash#[] &&      7.303M (± 0.6%) i/s  (136.93 ns/i) -     37.023M in   5.069773s
          Hash#fetch     12.634M (± 2.0%) i/s   (79.15 ns/i) -     63.570M in   5.033708s
 Hash#fetch fallback      8.117M (± 1.0%) i/s  (123.20 ns/i) -     40.967M in   5.047539s

Comparison:
            Hash#dig: 19434078.6 i/s
             Hash#[]: 19004999.7 i/s - same-ish: difference falls within error
          Hash#[] ||: 17879337.5 i/s - 1.09x  slower
          Hash#fetch: 12633982.2 i/s - 1.54x  slower
 Hash#fetch fallback:  8116930.3 i/s - 2.39x  slower
          Hash#[] &&:  7302991.9 i/s - 2.66x  slower
```

##### `Hash[]` vs `Hash#dup` [code](code/hash/bracket-vs-dup.rb)

Source: http://tenderlovemaking.com/2015/02/11/weird-stuff-with-hashes.html

> Does this mean that you should switch to Hash[]?
> Only if your benchmarks can prove that it’s a bottleneck.
> Please please please don’t change all of your code because
> this shows it’s faster. Make sure to measure your app performance first.

```
$ ruby -v code/hash/bracket-vs-dup.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
              Hash[]   684.060k i/100ms
            Hash#dup   612.214k i/100ms
Calculating -------------------------------------
              Hash[]      7.555M (± 2.8%) i/s  (132.37 ns/i) -     38.307M in   5.074888s
            Hash#dup      5.851M (± 2.1%) i/s  (170.90 ns/i) -     29.386M in   5.024310s

Comparison:
              Hash[]:  7554758.4 i/s
            Hash#dup:  5851408.7 i/s - 1.29x  slower
```

##### `Hash#fetch` with argument vs `Hash#fetch` + block [code](code/hash/fetch-vs-fetch-with-block.rb)

> Note that the speedup in the block version comes from avoiding repeated <br>
> construction of the argument. If the argument is a constant, number symbol or <br>
> something of that sort the argument version is actually slightly faster <br>
> See also [#39 (comment)](https://github.com/fastruby/fast-ruby/issues/39#issuecomment-103989335)

```
$ ruby -v code/hash/fetch-vs-fetch-with-block.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
  Hash#fetch + const     3.136M i/100ms
  Hash#fetch + block     3.313M i/100ms
    Hash#fetch + arg     2.266M i/100ms
Calculating -------------------------------------
  Hash#fetch + const     32.198M (± 1.0%) i/s   (31.06 ns/i) -    163.090M in   5.065722s
  Hash#fetch + block     33.319M (± 1.1%) i/s   (30.01 ns/i) -    168.953M in   5.071324s
    Hash#fetch + arg     22.838M (± 1.3%) i/s   (43.79 ns/i) -    115.561M in   5.060964s

Comparison:
  Hash#fetch + block: 33319415.6 i/s
  Hash#fetch + const: 32198246.2 i/s - 1.03x  slower
    Hash#fetch + arg: 22837560.4 i/s - 1.46x  slower
```

##### `Hash#each_key` instead of `Hash#keys.each` [code](code/hash/keys-each-vs-each_key.rb)

> `Hash#keys.each` allocates an array of keys;  <br>
> `Hash#each_key` iterates through the keys without allocating a new array.  <br>
> This is the reason why `Hash#each_key` exists.  <br>
> —— @sferik [rails/rails#17099](https://github.com/rails/rails/pull/17099)

```
$ ruby -v code/hash/keys-each-vs-each_key.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
      Hash#keys.each   494.495k i/100ms
       Hash#each_key   510.269k i/100ms
Calculating -------------------------------------
      Hash#keys.each      5.026M (± 0.5%) i/s  (198.95 ns/i) -     25.219M in   5.017574s
       Hash#each_key      5.118M (± 1.2%) i/s  (195.39 ns/i) -     26.024M in   5.085610s

Comparison:
       Hash#each_key:  5117890.6 i/s
      Hash#keys.each:  5026302.4 i/s - 1.02x  slower
```

#### `Hash#key?` instead of `Hash#keys.include?` [code](code/hash/keys-include-vs-key.rb)

> `Hash#keys.include?` allocates an array of keys and performs an O(n) search; <br>
> `Hash#key?` performs an O(1) hash lookup without allocating a new array.

```
$ ruby -v code/hash/keys-include-vs-key.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
  Hash#keys.include?     2.217k i/100ms
           Hash#key?     2.683M i/100ms
Calculating -------------------------------------
  Hash#keys.include?     26.005k (± 5.6%) i/s   (38.45 μs/i) -    130.803k in   5.047937s
           Hash#key?     26.686M (± 1.3%) i/s   (37.47 ns/i) -    134.156M in   5.028106s

Comparison:
           Hash#key?: 26685586.3 i/s
  Hash#keys.include?:    26005.2 i/s - 1026.16x  slower
```

##### `Hash#value?` instead of `Hash#values.include?` [code](code/hash/values-include-vs-value.rb)

> `Hash#values.include?` allocates an array of values and performs an O(n) search; <br>
> `Hash#value?` performs an O(n) search without allocating a new array.

```
$ ruby -v code/hash/values-include-vs-value.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
Hash#values.include?     5.620k i/100ms
         Hash#value?     7.474k i/100ms
Calculating -------------------------------------
Hash#values.include?     62.053k (± 2.8%) i/s   (16.12 μs/i) -    314.720k in   5.076009s
         Hash#value?     71.151k (± 4.4%) i/s   (14.05 μs/i) -    358.752k in   5.051774s

Comparison:
         Hash#value?:    71150.8 i/s
Hash#values.include?:    62052.8 i/s - 1.15x  slower
```

##### `Hash#merge!` vs `Hash#[]=` [code](code/hash/merge-bang-vs-\[\]=.rb)

```
$ ruby -v code/hash/merge-bang-vs-[]=.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
         Hash#merge!     8.974k i/100ms
            Hash#[]=    20.052k i/100ms
Calculating -------------------------------------
         Hash#merge!     91.391k (± 0.5%) i/s   (10.94 μs/i) -    457.674k in   5.008010s
            Hash#[]=    202.686k (± 0.9%) i/s    (4.93 μs/i) -      1.023M in   5.045877s

Comparison:
            Hash#[]=:   202686.0 i/s
         Hash#merge!:    91390.8 i/s - 2.22x  slower
```

##### `Hash#update` vs `Hash#[]=` [code](code/hash/update-vs-\[\]=.rb)

```
$ ruby -v code/hash/update-vs-[]=.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
            Hash#[]=    19.739k i/100ms
         Hash#update     9.126k i/100ms
Calculating -------------------------------------
            Hash#[]=    202.714k (± 1.1%) i/s    (4.93 μs/i) -      1.026M in   5.064063s
         Hash#update     91.615k (± 0.7%) i/s   (10.92 μs/i) -    465.426k in   5.080450s

Comparison:
            Hash#[]=:   202713.9 i/s
         Hash#update:    91615.2 i/s - 2.21x  slower
```

##### `Hash#merge` vs `Hash#**other` [code](code/hash/merge-vs-double-splat-operator.rb)

```
$ ruby -v code/hash/merge-vs-double-splat-operator.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
        Hash#**other   979.615k i/100ms
          Hash#merge   798.516k i/100ms
Calculating -------------------------------------
        Hash#**other      9.846M (± 0.3%) i/s  (101.57 ns/i) -     49.960M in   5.074265s
          Hash#merge      7.968M (± 0.3%) i/s  (125.50 ns/i) -     39.926M in   5.010730s

Comparison:
        Hash#**other:  9845909.6 i/s
          Hash#merge:  7968122.7 i/s - 1.24x  slower
```

##### `Hash#merge` vs `Hash#merge!` [code](code/hash/merge-vs-merge-bang.rb)

```
$ ruby -v code/hash/merge-vs-merge-bang.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
          Hash#merge     3.800k i/100ms
         Hash#merge!     9.310k i/100ms
Calculating -------------------------------------
          Hash#merge     38.042k (± 1.9%) i/s   (26.29 μs/i) -    193.800k in   5.096234s
         Hash#merge!     94.284k (± 0.4%) i/s   (10.61 μs/i) -    474.810k in   5.036016s

Comparison:
         Hash#merge!:    94284.1 i/s
          Hash#merge:    38041.7 i/s - 2.48x  slower
```

##### `{}#merge!(Hash)` vs `Hash#merge({})` vs `Hash#dup#merge!({})` [code](code/hash/merge-bang-vs-merge-vs-dup-merge-bang.rb)

> When we don't want to modify the original hash, and we want duplicates to be created <br>
> See [#42](https://github.com/fastruby/fast-ruby/pull/42#issue-93502261) for more details.

```
$ ruby -v code/hash/merge-bang-vs-merge-vs-dup-merge-bang.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
{}#merge!(Hash) do end
                        11.079k i/100ms
      Hash#merge({})     9.290k i/100ms
 Hash#dup#merge!({})     6.957k i/100ms
Calculating -------------------------------------
{}#merge!(Hash) do end
                        111.999k (± 0.3%) i/s    (8.93 μs/i) -    565.029k in   5.045023s
      Hash#merge({})     93.149k (± 0.4%) i/s   (10.74 μs/i) -    473.790k in   5.086441s
 Hash#dup#merge!({})     69.802k (± 0.4%) i/s   (14.33 μs/i) -    354.807k in   5.083113s

Comparison:
{}#merge!(Hash) do end:   111998.6 i/s
      Hash#merge({}):    93149.0 i/s - 1.20x  slower
 Hash#dup#merge!({}):    69802.3 i/s - 1.60x  slower
```

##### `Hash#sort_by` vs `Hash#sort` [code](code/hash/hash-key-sort_by-vs-sort.rb)

To sort hash by key.

```
$ ruby -v code/hash/hash-key-sort_by-vs-sort.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
      sort_by + to_h    72.056k i/100ms
         sort + to_h    26.595k i/100ms
Calculating -------------------------------------
      sort_by + to_h    739.508k (± 0.7%) i/s    (1.35 μs/i) -      3.747M in   5.067024s
         sort + to_h    269.700k (± 1.9%) i/s    (3.71 μs/i) -      1.356M in   5.030958s

Comparison:
      sort_by + to_h:   739507.8 i/s
         sort + to_h:   269700.3 i/s - 2.74x  slower
```

##### Native `Hash#slice` vs other slice implementations before native [code](code/hash/slice-native-vs-before-native.rb)

Since ruby 2.5, Hash comes with a `slice` method to select hash members by keys.

```
$ ruby -v code/hash/slice-native-vs-before-native.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
Hash#native-slice        1.024M i/100ms
Array#each             467.292k i/100ms
Array#each_w/_object   388.528k i/100ms
Hash#select-include    131.358k i/100ms
Calculating -------------------------------------
Hash#native-slice        10.550M (± 1.4%) i/s   (94.78 ns/i) -     53.251M in   5.048257s
Array#each                4.688M (± 0.5%) i/s  (213.30 ns/i) -     23.832M in   5.083384s
Array#each_w/_object      3.890M (± 0.4%) i/s  (257.07 ns/i) -     19.815M in   5.093848s
Hash#select-include       1.343M (± 1.7%) i/s  (744.63 ns/i) -      6.831M in   5.087848s

Comparison:
Hash#native-slice   : 10550464.1 i/s
Array#each          :  4688305.3 i/s - 2.25x  slower
Array#each_w/_object:  3890033.7 i/s - 2.71x  slower
Hash#select-include :  1342942.2 i/s - 7.86x  slower
```


### Proc & Block

##### Block vs `Symbol#to_proc` [code](code/proc-and-block/block-vs-to_proc.rb)

> `Symbol#to_proc` is considerably more concise than using block syntax. <br>
> ...In some cases, it reduces the number of lines of code. <br>
> —— @sferik [rails/rails#16833](https://github.com/rails/rails/pull/16833)

```
$ ruby -v code/proc-and-block/block-vs-to_proc.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
               Block    20.147k i/100ms
      Symbol#to_proc    22.231k i/100ms
Calculating -------------------------------------
               Block    202.937k (± 0.4%) i/s    (4.93 μs/i) -      1.027M in   5.063220s
      Symbol#to_proc    222.450k (± 0.9%) i/s    (4.50 μs/i) -      1.134M in   5.097179s

Comparison:
      Symbol#to_proc:   222449.5 i/s
               Block:   202937.5 i/s - 1.10x  slower
```

##### `Proc#call` and block arguments vs `yield` [code](code/proc-and-block/proc-call-vs-yield.rb)

```
$ ruby -v code/proc-and-block/proc-call-vs-yield.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
          block.call     2.261M i/100ms
       block + yield     2.314M i/100ms
        unused block     3.025M i/100ms
               yield     2.971M i/100ms
Calculating -------------------------------------
          block.call     22.057M (± 6.0%) i/s   (45.34 ns/i) -    110.796M in   5.043129s
       block + yield     23.280M (± 0.6%) i/s   (42.96 ns/i) -    117.997M in   5.068779s
        unused block     30.609M (± 1.3%) i/s   (32.67 ns/i) -    154.268M in   5.040991s
               yield     29.921M (± 0.6%) i/s   (33.42 ns/i) -    151.512M in   5.063842s

Comparison:
        unused block: 30608512.5 i/s
               yield: 29921356.8 i/s - 1.02x  slower
       block + yield: 23279981.0 i/s - 1.31x  slower
          block.call: 22056758.6 i/s - 1.39x  slower
```

### String

##### `String#dup` vs `String#+` [code](code/string/dup-vs-unary-plus.rb)

Note that `String.new` is not the same as the options compared, since it is
always `ASCII-8BIT` encoded instead of the script encoding (usually `UTF-8`).

```
$ ruby -v code/string/dup-vs-unary-plus.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
           String#+@     2.439M i/100ms
          String#dup     2.481M i/100ms
Calculating -------------------------------------
           String#+@     24.328M (± 0.5%) i/s   (41.10 ns/i) -    121.962M in   5.013305s
          String#dup     24.553M (± 1.0%) i/s   (40.73 ns/i) -    124.040M in   5.052462s

Comparison:
          String#dup: 24552887.2 i/s
           String#+@: 24328187.6 i/s - same-ish: difference falls within error
```

##### `String#casecmp` vs  `String#casecmp?` vs `String#downcase + ==` [code](code/string/casecmp-vs-downcase-==.rb)

`String#casecmp?` is available on Ruby 2.4 or later.
Note that `String#casecmp` only works on characters A-Z/a-z, not all of Unicode.

```
$ ruby -v code/string/casecmp-vs-downcase-==.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
     String#casecmp?     1.053M i/100ms
String#downcase + ==     1.467M i/100ms
      String#casecmp     1.816M i/100ms
Calculating -------------------------------------
     String#casecmp?     10.916M (± 1.4%) i/s   (91.61 ns/i) -     54.769M in   5.018429s
String#downcase + ==     14.673M (± 1.0%) i/s   (68.15 ns/i) -     74.808M in   5.098814s
      String#casecmp     18.210M (± 0.7%) i/s   (54.91 ns/i) -     92.594M in   5.084879s

Comparison:
      String#casecmp: 18210413.9 i/s
String#downcase + ==: 14673089.8 i/s - 1.24x  slower
     String#casecmp?: 10915954.0 i/s - 1.67x  slower
```

##### String Concatenation [code](code/string/concatenation.rb)

```
$ ruby -v code/string/concatenation.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
            String#+     1.214M i/100ms
       String#concat     1.407M i/100ms
       String#append     1.561M i/100ms
         "foo" "bar"     2.723M i/100ms
  "#{'foo'}#{'bar'}"     2.914M i/100ms
Calculating -------------------------------------
            String#+     12.616M (± 0.9%) i/s   (79.27 ns/i) -     63.138M in   5.005092s
       String#concat     14.555M (± 1.1%) i/s   (68.71 ns/i) -     73.188M in   5.029155s
       String#append     15.844M (± 0.7%) i/s   (63.12 ns/i) -     79.634M in   5.026390s
         "foo" "bar"     27.318M (± 0.8%) i/s   (36.61 ns/i) -    138.888M in   5.084517s
  "#{'foo'}#{'bar'}"     29.063M (± 0.5%) i/s   (34.41 ns/i) -    145.707M in   5.013531s

Comparison:
  "#{'foo'}#{'bar'}": 29063458.4 i/s
         "foo" "bar": 27317882.5 i/s - 1.06x  slower
       String#append: 15843896.8 i/s - 1.83x  slower
       String#concat: 14554534.2 i/s - 2.00x  slower
            String#+: 12615859.7 i/s - 2.30x  slower
```

##### `String#match` vs `String.match?` vs `String#start_with?`/`String#end_with?` [code (start)](code/string/start-string-checking-match-vs-start_with.rb) [code (end)](code/string/end-string-checking-match-vs-end_with.rb)

The regular expression approaches become slower as the tested string becomes
longer. For short strings, `String#match?` performs similarly to
`String#start_with?`/`String#end_with?`.

> :warning: <br>
> Sometimes you cant replace regexp with `start_with?`, <br>
> for example: `"a\nb" =~ /^b/ #=> 2` but `"a\nb" =~ /\Ab/ #=> nil`.<br>
> :warning: <br>

```
$ ruby -v code/string/start-string-checking-match-vs-start_with.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
           String#=~   704.323k i/100ms
       String#match?     1.696M i/100ms
  String#start_with?     2.002M i/100ms
Calculating -------------------------------------
           String#=~      7.155M (± 0.9%) i/s  (139.76 ns/i) -     35.920M in   5.020673s
       String#match?     17.088M (± 0.7%) i/s   (58.52 ns/i) -     86.478M in   5.061156s
  String#start_with?     20.186M (± 1.0%) i/s   (49.54 ns/i) -    102.087M in   5.057969s

Comparison:
  String#start_with?: 20185554.4 i/s
       String#match?: 17087554.1 i/s - 1.18x  slower
           String#=~:  7155069.8 i/s - 2.82x  slower
```

```
$ ruby -v code/string/end-string-checking-match-vs-end_with.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
           String#=~   459.289k i/100ms
       String#match?   808.294k i/100ms
    String#end_with?     1.358M i/100ms
Calculating -------------------------------------
           String#=~      4.900M (± 0.7%) i/s  (204.10 ns/i) -     24.802M in   5.062282s
       String#match?      7.999M (± 3.2%) i/s  (125.02 ns/i) -     40.415M in   5.058576s
    String#end_with?     13.797M (± 0.9%) i/s   (72.48 ns/i) -     69.248M in   5.019420s

Comparison:
    String#end_with?: 13797085.6 i/s
       String#match?:  7998569.4 i/s - 1.72x  slower
           String#=~:  4899556.6 i/s - 2.82x  slower
```

##### `String#start_with?` vs `String#[].==` [code](code/string/start_with-vs-substring-==.rb)

```
$ ruby -v code/string/start_with-vs-substring-==.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
  String#start_with?   405.198k i/100ms
    String#[0, n] ==   185.548k i/100ms
   String#[RANGE] ==   183.537k i/100ms
   String#[0...n] ==   111.844k i/100ms
Calculating -------------------------------------
  String#start_with?      4.336M (± 1.7%) i/s  (230.64 ns/i) -     21.881M in   5.048171s
    String#[0, n] ==      1.911M (± 1.8%) i/s  (523.18 ns/i) -      9.648M in   5.049643s
   String#[RANGE] ==      1.835M (± 1.4%) i/s  (544.95 ns/i) -      9.177M in   5.001963s
   String#[0...n] ==      1.100M (± 1.5%) i/s  (909.34 ns/i) -      5.592M in   5.086419s

Comparison:
  String#start_with?:  4335677.0 i/s
    String#[0, n] ==:  1911392.8 i/s - 2.27x  slower
   String#[RANGE] ==:  1835034.3 i/s - 2.36x  slower
   String#[0...n] ==:  1099697.5 i/s - 3.94x  slower
```

##### `Regexp#===` vs `Regexp#match` vs `Regexp#match?` vs `String#match` vs `String#=~` vs `String#match?` [code ](code/string/===-vs-=~-vs-match.rb)

`String#match?` and `Regexp#match?` are available on Ruby 2.4 or later.
ActiveSupport [provides](http://guides.rubyonrails.org/v5.1/active_support_core_extensions.html#match-questionmark)
a forward compatible extension of `Regexp` for older Rubies without the speed
improvement.

> :warning: <br>
> Sometimes you can't replace `match` with `match?`, <br>
> This is only useful for cases where you are checking <br>
> for a match and not using the resultant match object. <br>
> :warning: <br>
> `Regexp#===` is also faster than `String#match` but you need to switch the order of arguments.

```
$ ruby -v code/string/===-vs-=~-vs-match.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
       Regexp#match?     2.240M i/100ms
       String#match?     2.271M i/100ms
           String#=~     1.322M i/100ms
          Regexp#===     1.252M i/100ms
        Regexp#match     1.187M i/100ms
        String#match     1.024M i/100ms
Calculating -------------------------------------
       Regexp#match?     22.395M (± 1.3%) i/s   (44.65 ns/i) -    111.995M in   5.001594s
       String#match?     22.544M (± 1.4%) i/s   (44.36 ns/i) -    113.533M in   5.037001s
           String#=~     13.285M (± 2.6%) i/s   (75.27 ns/i) -     67.438M in   5.079611s
          Regexp#===     12.472M (± 0.6%) i/s   (80.18 ns/i) -     62.618M in   5.020860s
        Regexp#match     11.865M (± 0.8%) i/s   (84.28 ns/i) -     59.340M in   5.001611s
        String#match     10.223M (± 0.7%) i/s   (97.81 ns/i) -     51.194M in   5.007796s

Comparison:
       String#match?: 22544340.1 i/s
       Regexp#match?: 22395457.7 i/s - same-ish: difference falls within error
           String#=~: 13285297.2 i/s - 1.70x  slower
          Regexp#===: 12471978.3 i/s - 1.81x  slower
        Regexp#match: 11864949.7 i/s - 1.90x  slower
        String#match: 10223419.6 i/s - 2.21x  slower
```

See [#59](https://github.com/fastruby/fast-ruby/pull/59) and [#62](https://github.com/fastruby/fast-ruby/pull/62) for discussions.


##### `String#gsub` vs `String#sub` vs `String#[]=` [code](code/string/gsub-vs-sub.rb)

```
$ ruby -v code/string/gsub-vs-sub.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
         String#gsub   230.980k i/100ms
          String#sub   465.575k i/100ms
String#dup["string"]=
                       838.284k i/100ms
Calculating -------------------------------------
         String#gsub      2.338M (± 0.9%) i/s  (427.64 ns/i) -     11.780M in   5.038072s
          String#sub      4.691M (± 1.2%) i/s  (213.16 ns/i) -     23.744M in   5.062169s
String#dup["string"]=
                          8.433M (± 1.0%) i/s  (118.58 ns/i) -     42.752M in   5.070311s

Comparison:
String#dup["string"]=:  8432793.1 i/s
          String#sub:  4691246.0 i/s - 1.80x  slower
         String#gsub:  2338396.7 i/s - 3.61x  slower
```

##### `String#gsub` vs `String#tr` [code](code/string/gsub-vs-tr.rb)

> [rails/rails#17257](https://github.com/rails/rails/pull/17257)

```
$ ruby -v code/string/gsub-vs-tr.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
         String#gsub   297.314k i/100ms
           String#tr   914.116k i/100ms
Calculating -------------------------------------
         String#gsub      3.032M (± 0.8%) i/s  (329.83 ns/i) -     15.163M in   5.001554s
           String#tr      9.136M (± 0.8%) i/s  (109.46 ns/i) -     45.706M in   5.003201s

Comparison:
           String#tr:  9135960.5 i/s
         String#gsub:  3031853.2 i/s - 3.01x  slower
```

##### `String#gsub` vs `String#tr` vs `String#delete` [code](code/string/gsub-vs-tr-vs-delete.rb)

```
$ ruby -v code/string/gsub-vs-tr-vs-delete.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
         String#gsub   314.117k i/100ms
           String#tr   989.154k i/100ms
       String#delete     1.159M i/100ms
 String#delete const     1.320M i/100ms
Calculating -------------------------------------
         String#gsub      3.099M (± 1.1%) i/s  (322.65 ns/i) -     15.706M in   5.068096s
           String#tr      9.868M (± 1.3%) i/s  (101.34 ns/i) -     49.458M in   5.012992s
       String#delete     11.623M (± 0.6%) i/s   (86.03 ns/i) -     59.109M in   5.085570s
 String#delete const     13.192M (± 0.8%) i/s   (75.80 ns/i) -     65.989M in   5.002525s

Comparison:
 String#delete const: 13191917.5 i/s
       String#delete: 11623217.0 i/s - 1.13x  slower
           String#tr:  9867528.0 i/s - 1.34x  slower
         String#gsub:  3099363.7 i/s - 4.26x  slower
```

##### `Mutable` vs `Immutable` [code](code/string/mutable_vs_immutable_strings.rb)

```
$ ruby -v code/string/mutable_vs_immutable_strings.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
      Without Freeze     2.671M i/100ms
         With Freeze     4.464M i/100ms
Calculating -------------------------------------
      Without Freeze     27.091M (± 1.6%) i/s   (36.91 ns/i) -    136.216M in   5.029377s
         With Freeze     44.763M (± 0.9%) i/s   (22.34 ns/i) -    227.646M in   5.085943s

Comparison:
         With Freeze: 44763124.8 i/s
      Without Freeze: 27091288.1 i/s - 1.65x  slower
```


##### `String#sub!` vs `String#gsub!` vs `String#[]=` [code](code/string/sub!-vs-gsub!-vs-[]=.rb)

Note that `String#[]` will throw an `IndexError` when given string or regexp not matched.

```
$ ruby -v code/string/sub!-vs-gsub!-vs-[]=.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
  String#['string']=   867.608k i/100ms
 String#sub!'string'   452.774k i/100ms
String#gsub!'string'   219.002k i/100ms
  String#[/regexp/]=   484.258k i/100ms
 String#sub!/regexp/   439.965k i/100ms
String#gsub!/regexp/   222.202k i/100ms
Calculating -------------------------------------
  String#['string']=      8.875M (± 0.9%) i/s  (112.67 ns/i) -     45.116M in   5.083636s
 String#sub!'string'      4.648M (± 0.6%) i/s  (215.15 ns/i) -     23.544M in   5.065834s
String#gsub!'string'      2.234M (± 0.6%) i/s  (447.72 ns/i) -     11.169M in   5.000776s
  String#[/regexp/]=      4.913M (± 0.6%) i/s  (203.54 ns/i) -     24.697M in   5.026953s
 String#sub!/regexp/      4.474M (± 0.4%) i/s  (223.50 ns/i) -     22.438M in   5.014974s
String#gsub!/regexp/      2.221M (± 0.7%) i/s  (450.25 ns/i) -     11.110M in   5.002620s

Comparison:
  String#['string']=:  8875438.0 i/s
  String#[/regexp/]=:  4913121.6 i/s - 1.81x  slower
 String#sub!'string':  4647843.8 i/s - 1.91x  slower
 String#sub!/regexp/:  4474302.7 i/s - 1.98x  slower
String#gsub!'string':  2233558.9 i/s - 3.97x  slower
String#gsub!/regexp/:  2220978.6 i/s - 4.00x  slower
```

##### `String#sub` vs `String#delete_prefix` [code](code/string/sub-vs-delete_prefix.rb)

[Ruby 2.5 introduced](https://bugs.ruby-lang.org/issues/12694) `String#delete_prefix`.
Note that this can only be used for removing characters from the start of a string.

```
$ ruby -v code/string/sub-vs-delete_prefix.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
String#delete_prefix     1.446M i/100ms
          String#sub   473.108k i/100ms
Calculating -------------------------------------
String#delete_prefix     14.867M (± 1.3%) i/s   (67.26 ns/i) -     75.200M in   5.059147s
          String#sub      4.726M (± 0.7%) i/s  (211.58 ns/i) -     23.655M in   5.005369s

Comparison:
String#delete_prefix: 14866723.8 i/s
          String#sub:  4726255.3 i/s - 3.15x  slower
```

##### `String#sub` vs `String#chomp` vs `String#delete_suffix` [code](code/string/sub-vs-chomp-vs-delete_suffix.rb)

[Ruby 2.5 introduced](https://bugs.ruby-lang.org/issues/13665) `String#delete_suffix`
as a counterpart to `delete_prefix`. The performance gain over `chomp` is
small and during some runs the difference falls within the error margin.
Note that this can only be used for removing characters from the end of a string.

```
$ ruby -v code/string/sub-vs-chomp-vs-delete_suffix.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
          String#sub   472.278k i/100ms
        String#chomp     1.354M i/100ms
String#delete_suffix     1.477M i/100ms
Calculating -------------------------------------
          String#sub      4.809M (± 1.0%) i/s  (207.93 ns/i) -     24.086M in   5.008842s
        String#chomp     13.829M (± 1.2%) i/s   (72.31 ns/i) -     70.425M in   5.093208s
String#delete_suffix     14.936M (± 0.9%) i/s   (66.95 ns/i) -     75.317M in   5.042961s

Comparison:
String#delete_suffix: 14936380.8 i/s
        String#chomp: 13829135.7 i/s - 1.08x  slower
          String#sub:  4809249.5 i/s - 3.11x  slower
```

##### `String#unpack1` vs `String#unpack[0]` [code](code/string/unpack1-vs-unpack[0].rb)

[Ruby 2.4.0 introduced `unpack1`](https://bugs.ruby-lang.org/issues/12752) to skip creating the intermediate array object.

```
$ ruby -v code/string/unpack1-vs-unpack[0].rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
      String#unpack1     1.372M i/100ms
    String#unpack[0]     1.095M i/100ms
Calculating -------------------------------------
      String#unpack1     14.219M (± 0.7%) i/s   (70.33 ns/i) -     71.349M in   5.018051s
    String#unpack[0]     11.071M (± 1.2%) i/s   (90.33 ns/i) -     55.839M in   5.044380s

Comparison:
      String#unpack1: 14219190.8 i/s
    String#unpack[0]: 11071030.6 i/s - 1.28x  slower
```

##### Remove extra spaces (or other contiguous characters) [code](code/string/remove-extra-spaces-or-other-chars.rb)

The code is tested against contiguous spaces but should work for other chars too.

```
$ ruby -v code/string/remove-extra-spaces-or-other-chars.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
 String#gsub/regex+/    15.087k i/100ms
      String#squeeze   429.561k i/100ms
Calculating -------------------------------------
 String#gsub/regex+/    152.509k (± 0.6%) i/s    (6.56 μs/i) -    769.437k in   5.045412s
      String#squeeze      4.264M (± 1.7%) i/s  (234.51 ns/i) -     21.478M in   5.038218s

Comparison:
      String#squeeze:  4264261.4 i/s
 String#gsub/regex+/:   152508.7 i/s - 27.96x  slower
```

### Time

##### `Time.iso8601` vs `Time.parse` [code](code/time/iso8601-vs-parse.rb)

When expecting well-formatted data from e.g. an API, `iso8601` is faster and will raise an `ArgumentError` on malformed input.

```
$ ruby -v code/time/iso8601-vs-parse.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
        Time.iso8601   105.846k i/100ms
          Time.parse    19.826k i/100ms
Calculating -------------------------------------
        Time.iso8601      1.076M (± 0.5%) i/s  (929.16 ns/i) -      5.398M in   5.015850s
          Time.parse    200.370k (± 0.8%) i/s    (4.99 μs/i) -      1.011M in   5.046598s

Comparison:
        Time.iso8601:  1076241.3 i/s
          Time.parse:   200370.2 i/s - 5.37x  slower
```

### Range

##### `cover?` vs `include?` [code](code/range/cover-vs-include.rb)

`cover?` only check if it is within the start and end, `include?` needs to traverse the whole range.

```
$ ruby -v code/range/cover-vs-include.rb
ruby 4.0.0 (2025-12-25 revision 553f1675f3) +PRISM [arm64-darwin24]
Warming up --------------------------------------
        range#cover?   811.176k i/100ms
      range#include?    34.101k i/100ms
       range#member?    35.591k i/100ms
       plain compare     1.131M i/100ms
      value.between?     1.520M i/100ms
Calculating -------------------------------------
        range#cover?      8.324M (± 0.3%) i/s  (120.14 ns/i) -     42.181M in   5.067623s
      range#include?    352.846k (± 1.7%) i/s    (2.83 μs/i) -      1.773M in   5.027064s
       range#member?    349.526k (± 1.9%) i/s    (2.86 μs/i) -      1.780M in   5.093144s
       plain compare     11.296M (± 1.3%) i/s   (88.53 ns/i) -     56.554M in   5.007498s
      value.between?     15.214M (± 0.9%) i/s   (65.73 ns/i) -     77.527M in   5.096183s

Comparison:
      value.between?: 15213944.1 i/s
       plain compare: 11295903.4 i/s - 1.35x  slower
        range#cover?:  8323723.8 i/s - 1.83x  slower
      range#include?:   352846.2 i/s - 43.12x  slower
       range#member?:   349526.0 i/s - 43.53x  slower
```


## Less idiomatic but with significant performance ruby

Checkout: https://github.com/fastruby/fast-ruby/wiki/Less-idiomatic-but-with-significant-performance-difference


## Submit New Entry

Please! [Edit this README.md](https://github.com/fastruby/fast-ruby/edit/main/README.md) then [Submit a Awesome Pull Request](https://github.com/fastruby/fast-ruby/pulls)!


## Something went wrong

Code example is wrong? :cry: Got better example? :heart_eyes: Excellent!

[Please open an issue](https://github.com/fastruby/fast-ruby/issues/new) or [Open a Pull Request](https://github.com/fastruby/fast-ruby/pulls) to fix it.

Thank you in advance! :wink: :beer:


## One more thing

[Share this with your #Rubyfriends! <3](https://twitter.com/intent/tweet?url=http%3A%2F%2Fgit.io%2F4U3xdw&text=Fast%20Ruby%20--%20Common%20Ruby%20Idioms%20inspired%20by%20%40sferik&original_referer=&via=juanitofatas&hashtags=#RubyFriends)

Brought to you by [@JuanitoFatas](https://twitter.com/juanitofatas)

Feel free to talk with me on Twitter! <3


## Also Checkout

- [Derailed Benchmarks](https://github.com/schneems/derailed_benchmarks)

  Go faster, off the Rails - Benchmarks for your whole Rails app

- [Benchmarking Ruby](https://speakerdeck.com/davystevenson/benchmarking-ruby)

  Talk by Davy Stevenson @ RubyConf 2014.

- [davy/benchmark-bigo](https://github.com/davy/benchmark-bigo)

  Provides Big O notation benchmarking for Ruby.

- [The Ruby Challenge](https://www.youtube.com/watch?v=aDeP7FGQBig)

  Talk by Prem Sichanugrist @ Ruby Kaigi 2014.

- [Fasterer](https://github.com/DamirSvrtan/fasterer)

  Make your Rubies go faster with this command line tool.


## License

![CC-BY-SA](CC-BY-SA.png)

This work is licensed under a [Creative Commons Attribution-ShareAlike 4.0 International License](https://creativecommons.org/licenses/by-sa/4.0/).


## Code License

### CC0 1.0 Universal

To the extent possible under law, @JuanitoFatas has waived all copyright and related or neighboring rights to "fast-ruby".

This work belongs to the community.
