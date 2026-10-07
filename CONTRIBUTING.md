Thank you for checking in!

If you find any typos, errors, or have an better example. Just raise a new issue or open a pull request!

<3

These idioms list here are trying to satisfy following goals:

[![GOALS](/images/Goals.png)](https://speakerdeck.com/sferik/writing-fast-ruby?slide=11)

## Contents

- [Note on entry](#note-on-entry)
- [Running it on other Rubies](#running-it-on-other-rubies)
- [The results site](#the-results-site)
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
Name them by rank and list the winner first.
The names grow outward from the line between fast and slow: the recommended side uses `fast`, then `faster`, then `fastest`; the other side uses `slow`, then `slower`, then `slowest`.
The names are relative: `slow` only means slower than `fast`.
When a ranking could look odd, say why in one line, like in `code/array/length-vs-size-vs-count.rb`:

```ruby
def faster
  ARRAY.length
end

# Array#size is an alias of Array#length, so these two should tie.
def fast
  ARRAY.size
end

def slow
  ARRAY.count
end

Benchmark.ips do |x|
  x.report("Array#length") { faster }
  x.report("Array#size") { fast }
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

## The results site

The results site (https://fastruby.github.io/fast-ruby/) compares Rubies, so every build of a benchmark has to run on the same machine.
`script/run_cross_ruby.rb` (Ruby 3 on your machine, it calls Docker) does that, and runs the newest released MRI again after every 3 builds, so the site can show how steady the machine was.
To see a few benchmarks the way the site shows them, run them on a few builds, build the site into `_site/`, then open `_site/index.html` in a browser:

```
ruby script/run_cross_ruby.rb --files code/date/iso8601-vs-parse.rb,code/string/gsub-vs-tr.rb --builds ruby_3.4,ruby_3.4+yjit,ruby_4.0 --out cross-ruby
docker compose run --rm -T --entrypoint ruby ruby_4.0 script/build_results_site.rb cross-ruby _site
```

`ruby script/run_cross_ruby.rb --help` lists the options.
The builds are the ones in the CI matrix (`.github/workflows/benchmarks.yml`), so a new Ruby added there and in `compose.yaml` is measured too, and once released it becomes both the reference and the Ruby the site opens on.
On an Apple silicon Mac, leave out `ruby_2.1` and `jruby_9.1` (they run under emulation, so their numbers are not comparable) and `ruby_3.1+yjit` (Ruby 3.1's YJIT only exists on x86-64).

CI has two workflows:

- `.github/workflows/benchmarks.yml` checks that every benchmark runs on every Ruby: on a PR, the benchmark files it changes; on `main`, all of them when a benchmark or a shared file changed. It publishes nothing.
- `.github/workflows/results-site.yml` runs every build on every file once a week, split over 6 machines, and publishes the site. Run it by hand from the Actions tab to publish sooner.

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
