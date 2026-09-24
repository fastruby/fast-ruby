Thank you for checking in!

If you find any typos, errors, or have an better example. Just raise a new issue or open a pull request!

<3

These idioms list here are trying to satisfy following goals:

[![GOALS](/images/Goals.png)](https://speakerdeck.com/sferik/writing-fast-ruby?slide=11)

## Contents

- [Note on entry](#note-on-entry)
- [Running it on other Rubies](#running-it-on-other-rubies)
- [Benchmarks that need a newer Ruby](#benchmarks-that-need-a-newer-ruby)
- [License](#license)

## Note on entry

Fast code first.

```ruby
require 'benchmark/ips'

def fast
end

def slow
end

Benchmark.ips do |x|
  x.report('fast code description') { fast }
  x.report('slow code description') { slow }
  x.compare!
end
```

Keep that shape: end every `Benchmark.ips` block with `x.compare!`, keep the
default timing (no `Benchmark.ips(20)`, `x.time = ...` or `x.config(time: ...)`),
so every entry is measured the same way, and make sure
the file actually calls `Benchmark.ips` when it runs
(not only inside a method nothing calls). CI checks these, and the naming below.

The method names say which report should win.
CI checks that exactly one report is named the winner and that it comes first.
Wrap every report in a method, so they all pay the same call cost.
Name them by rank and list the winner first: `fastest`, `faster`, `fast` at the top, then `slow`, `slower`, `slowest`.
The names are relative: `slow` only means slower than `fast`.
When a ranking could look odd, say why in one line, like in `code/array/length-vs-size-vs-count.rb`:

```ruby
def fastest
  ARRAY.length
end

# Array#size is an alias of Array#length, so these two should tie.
def faster
  ARRAY.size
end

def slow
  ARRAY.count
end

Benchmark.ips do |x|
  x.report("Array#length") { fastest }
  x.report("Array#size") { faster }
  x.report("Array#count") { slow }
  x.compare!
end
```

Run your result:

```
ruby -v code/your-new/entry.rb
```

## Running it on other Rubies

To run it on a Ruby you don't have installed, use Docker. There is one service
per Ruby in the CI matrix (see `compose.yaml`):

```
docker compose run --rm ruby_2.1 code/your-new/entry.rb
docker compose run --rm truffleruby_head code/your-new/entry.rb
```

Without a file argument, the service runs every benchmark, the same way CI does.

The `*_head` and `truffleruby_22` images are built once and then reused, so
the head builds go stale. To get the latest nightly build:

```
docker compose build --no-cache ruby_head
```

To run it with a JIT, pass the variant and its flags. The run stops if the
Ruby does not have that JIT, instead of quietly running without it:

```
RUBY_VARIANT=yjit RUBY_VARIANT_FLAGS=--yjit docker compose run --rm ruby_3.4 code/your-new/entry.rb
RUBY_VARIANT=zjit RUBY_VARIANT_FLAGS=--zjit docker compose run --rm ruby_4.0 code/your-new/entry.rb
```

To keep the results, set `RESULTS_DIR`. Each benchmark then also writes its
report as JSON to `results/<label>/`, with the Ruby, its flags and the machine
it ran on:

```
RESULTS_DIR=results RESULTS_LABEL=ruby_3.4 docker compose run --rm ruby_3.4 code/your-new/entry.rb
```

## Benchmarks that need a newer Ruby

CI runs every benchmark on every Ruby in `compose.yaml`, back to Ruby 2.1, and
fails when one crashes. If your entry uses something older Rubies do not have,
make it skip them.

Skip one report, so the rest still run everywhere:

```ruby
Benchmark.ips do |x|
  x.report('String#delete_suffix') { fast } if RUBY_VERSION >= '2.5.0'
  x.report('String#sub')           { slow }
  x.compare!
end
```

Skip the whole file when nothing in it makes sense without the feature:

```ruby
if RUBY_VERSION >= '2.5.0'
  # everything, including Benchmark.ips
end
```

New syntax (for example `<<~` before 2.3) cannot be skipped this way: older
Rubies fail to parse the file before the `if` runs. Write it with syntax they
understand instead.

To check an entry on an older Ruby, see [Running it on other Rubies](#running-it-on-other-rubies).

## License

Thanks in advance!!! Look forward to learning more from you!

<3 [JuanitoFatas](https://twitter.com/juanitofatas)

<small>The documentation is [CC BY-SA 4.0 (International)](https://github.com/JuanitoFatas/fast-ruby#license).</small>

<small>And code will be [CC0 1.0 Universal](https://github.com/JuanitoFatas/fast-ruby#code-license).</small>
