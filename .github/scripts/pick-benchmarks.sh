#!/bin/bash
# Decides what a CI run benchmarks, and writes `run` and `files` to
# $GITHUB_OUTPUT. Usage: pick-benchmarks.sh <base commit>
#
# A pull request runs only the benchmark files it changes, unless it changes
# something every benchmark depends on. A push to main runs everything, if
# anything that affects benchmarks changed.
set -e

base=$1

if ! git cat-file -e "$base^{commit}" 2>/dev/null; then
  echo "Base $base not found, running every benchmark"
  echo "run=true" >> "$GITHUB_OUTPUT"
  exit 0
fi

changed=$(git diff --name-only "$base" HEAD)
files=$(git diff --name-only --diff-filter=d "$base" HEAD -- 'code/**/*.rb' | tr '\n' ' ')

if echo "$changed" | grep -qE '^(Gemfile|Rakefile|compose\.yaml|docker/|\.github/workflows/benchmarks\.yml|\.github/scripts/)'; then
  echo "Shared files changed, running every benchmark"
  echo "run=true" >> "$GITHUB_OUTPUT"
elif [ -z "$files" ]; then
  # Docs only, or a PR that only deletes a benchmark.
  echo "No benchmark to run"
  echo "run=false" >> "$GITHUB_OUTPUT"
elif [ "$GITHUB_EVENT_NAME" = pull_request ]; then
  echo "Running: $files"
  echo "run=true" >> "$GITHUB_OUTPUT"
  echo "files=$files" >> "$GITHUB_OUTPUT"
else
  echo "Benchmarks changed, running every benchmark"
  echo "run=true" >> "$GITHUB_OUTPUT"
fi
