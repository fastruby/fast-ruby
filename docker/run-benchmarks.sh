#!/bin/sh
# Runs the benchmarks inside a container: all of them by default, or only the
# files passed as arguments. The Gemfile is copied out of the mounted repo so
# each Ruby resolves its own Gemfile.lock and never touches the one on the host.
set -e

mkdir -p /tmp/bundle
cp /app/Gemfile /tmp/bundle/Gemfile
export BUNDLE_GEMFILE=/tmp/bundle/Gemfile

bundle install

# A variant runs the same Ruby with flags, for example YJIT. The Rakefile starts
# one process per benchmark, so the flags go through the variable each engine
# reads, which every child process inherits.
if [ -n "$RUBY_VARIANT" ] || [ -n "$RUBY_VARIANT_FLAGS" ]; then
  engine=$(ruby -e 'print RUBY_ENGINE')
  if [ -n "$RUBY_VARIANT_FLAGS" ]; then
    case "$engine" in
      jruby) export JRUBY_OPTS="$JRUBY_OPTS $RUBY_VARIANT_FLAGS" ;;
      truffleruby) export TRUFFLERUBYOPT="$RUBY_VARIANT_FLAGS $TRUFFLERUBYOPT" ;;
      *) export RUBYOPT="$RUBY_VARIANT_FLAGS $RUBYOPT" ;;
    esac
  fi

  # Fail here rather than silently benchmark without the variant. TruffleRuby
  # prints nothing for its flags, so only an invalid one fails there.
  description=$(ruby -e 'print RUBY_DESCRIPTION')
  case "$engine:$RUBY_VARIANT" in
    ruby:yjit) expected="+YJIT" ;;
    ruby:zjit) expected="+ZJIT" ;;
    jruby:dev|jruby:nojit) expected="-jit" ;;
    *) expected="" ;;
  esac
  case "$description" in
    *"$expected"*) echo "Variant $RUBY_VARIANT: $description" ;;
    *) echo "Variant $RUBY_VARIANT is not on: $description" >&2; exit 1 ;;
  esac
fi

# Also write every result as JSON, see docker/collect_results.rb.
if [ -n "$RESULTS_DIR" ]; then
  export RUBYOPT="-r/app/docker/collect_results.rb $RUBYOPT"
fi

if [ "$#" -eq 0 ]; then
  exec bundle exec rake
fi

failed=""
for benchmark in "$@"; do
  echo "\$ ruby -v $benchmark"
  bundle exec ruby -v -W0 "$benchmark" || failed="$failed
$benchmark"
done

if [ -n "$failed" ]; then
  echo "Failed benchmarks:$failed" >&2
  echo >&2
  echo "If a benchmark needs a newer Ruby, make it skip older ones, see" \
    "\"Benchmarks that need a newer Ruby\" in CONTRIBUTING.md." >&2
  exit 1
fi
