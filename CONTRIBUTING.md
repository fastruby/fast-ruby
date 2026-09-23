Thank you for checking in!

If you find any typos, errors, or have an better example. Just raise a new issue or open a pull request!

<3

These idioms list here are trying to satisfy following goals:

[![GOALS](/images/Goals.png)](https://speakerdeck.com/sferik/writing-fast-ruby?slide=11)

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
$ ruby -v code/your-new/entry.rb
```

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

Thanks in advance!!! Look forward to learning more from you!

<3 [JuanitoFatas](https://twitter.com/juanitofatas)

###### License

<small>The documentation is [CC BY-SA 4.0 (International)](https://github.com/JuanitoFatas/fast-ruby#license).</small>

<small>And code will be [CC0 1.0 Universal](https://github.com/JuanitoFatas/fast-ruby#code-license).</small>
