#!/bin/bash
# The benchmarks-ok check.
# Passes when the lint passed and every benchmark job passed, or there was nothing to benchmark.
# Usage: check-benchmarks.sh <changes result> <lint result> <rake result>
set -e

echo "changes: $1, lint: $2, rake: $3"
[ "$1" = success ] && [ "$2" = success ] && { [ "$3" = success ] || [ "$3" = skipped ]; }
