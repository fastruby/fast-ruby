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
