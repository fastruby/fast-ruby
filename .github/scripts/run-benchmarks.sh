#!/bin/bash
# Runs one Ruby's benchmark job and keeps its output in benchmarks.log for
# report-failures.sh. Usage: FILES="..." run-benchmarks.sh <ruby service>
# Without FILES, every benchmark runs.
set -eo pipefail

# Unquoted on purpose: one argument per file. set -f keeps names like
# dig-vs-[]-vs-fetch.rb from being read as glob patterns.
set -f
# shellcheck disable=SC2086
docker compose run --rm -T "$1" $FILES 2>&1 | tee benchmarks.log
