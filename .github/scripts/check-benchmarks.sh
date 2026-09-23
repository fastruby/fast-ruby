#!/bin/bash
# The benchmarks-ok check. Passes when every benchmark job passed, or when
# there was nothing to benchmark. Usage: check-benchmarks.sh <changes result> <rake result>
set -e

echo "changes: $1, rake: $2"
[ "$1" = success ] && { [ "$2" = success ] || [ "$2" = skipped ]; }
