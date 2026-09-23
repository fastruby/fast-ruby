#!/bin/bash
# After a failed benchmark job: one annotation per failed benchmark, shown on
# the PR's changed files, and a list on the run's summary page.
# Usage: report-failures.sh <log file> <ruby service>
set -e

log=$1
ruby=$2

failed=$(sed -n '/^Failed benchmarks:/,$p' "$log" | grep -E '^code/.+\.rb$' || true)
[ -n "$failed" ] || exit 0

hint='If it needs a newer Ruby, make it skip older ones, see "Benchmarks that need a newer Ruby" in CONTRIBUTING.md.'

{
  echo "### Benchmarks that failed on $ruby"
  echo
  echo "$failed" | while read -r file; do echo "- \`$file\`"; done
  echo
  echo "$hint"
} >> "$GITHUB_STEP_SUMMARY"

echo "$failed" | while read -r file; do
  # Annotation properties cannot contain raw % , or :
  escaped=$(printf '%s' "$file" | sed 's/%/%25/g; s/,/%2C/g; s/:/%3A/g')
  echo "::error file=$escaped,title=Fails on $ruby::Crashed on $ruby. $hint"
done
