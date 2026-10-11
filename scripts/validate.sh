#!/usr/bin/env bash
# Runs every check in scripts/checks/ in order and sums their failures.
# Run one alone with: bash scripts/checks/<name>.sh
set -uo pipefail

HERE="$(cd "$(dirname "$0")" && pwd)"

CHECKS=(
  frontmatter
  readme-public
  readme-private
  readme-links
  bucket-readmes
  plugin-json
  bucket-readme-disk
  markdownlint
  invocation-mode
  setup-skills-merge
  wizard-write-env
  spec-file-name
  stale-router
  untrusted-data
  stale-translation
)

count_file="$(mktemp)"
trap 'rm -f "$count_file"' EXIT
export VALIDATE_COUNT_FILE="$count_file"

first=1
for check in "${CHECKS[@]}"; do
  [[ $first -eq 1 ]] || echo ""
  first=0
  if ! bash "$HERE/checks/$check.sh"; then
    echo "  FAIL: check $check did not run to completion" >&2
    echo x >> "$count_file"
  fi
done

errors=$(wc -l < "$count_file")

echo ""
if [[ $errors -eq 0 ]]; then
  echo "All checks passed."
  exit 0
else
  echo "$errors check(s) failed." >&2
  exit 1
fi
