#!/bin/sh
# Runs the benchmarks inside a container: all of them by default, or only the
# files passed as arguments. The Gemfile is copied out of the mounted repo so
# each Ruby resolves its own Gemfile.lock and never touches the one on the host.
set -e

mkdir -p /tmp/bundle
cp /app/Gemfile /tmp/bundle/Gemfile
export BUNDLE_GEMFILE=/tmp/bundle/Gemfile

bundle install

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
