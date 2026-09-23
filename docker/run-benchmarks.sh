#!/bin/sh
# Runs the benchmarks inside a container: all of them by default, or only the
# files passed as arguments. The Gemfile is copied out of the mounted repo so
# each Ruby resolves its own Gemfile.lock and never touches the one on the host.
set -e

mkdir -p /tmp/bundle
cp /app/Gemfile /tmp/bundle/Gemfile
export BUNDLE_GEMFILE=/tmp/bundle/Gemfile

bundle install

if [ "$#" -eq 0 ]; then
  exec bundle exec rake
fi

for benchmark in "$@"; do
  echo "\$ ruby -v $benchmark"
  bundle exec ruby -v -W0 "$benchmark"
done
