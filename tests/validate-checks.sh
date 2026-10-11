#!/usr/bin/env bash
# Each check under scripts/checks/ runs alone: exits 0 on the real repo, and a
# check fed a broken repo exits non-zero with its own message.
# Usage: bash tests/validate-checks.sh
set -uo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
failures=0
ok() { echo "  ok:   $*"; }
bad() { echo "  FAIL: $*" >&2; failures=$((failures + 1)); }

CHECKS=(frontmatter readme-public readme-private readme-links bucket-readmes
  plugin-json bucket-readme-disk markdownlint invocation-mode
  setup-skills-merge wizard-write-env spec-file-name stale-router untrusted-data)

echo "==> every check runs alone and passes on the real repo"
for c in "${CHECKS[@]}"; do
  f="$HERE/scripts/checks/$c.sh"
  out=""
  if [[ -f "$f" ]] && out="$(bash "$f" 2>&1)"; then
    ok "$c"
  else
    bad "$c: missing or failing alone"; grep FAIL <<< "$out" >&2
  fi
done

echo "==> a single check reports its own failure"
work="$(mktemp -d)"
trap 'rm -rf "$work"' EXIT
mkdir -p "$work/scripts" "$work/skills"
cp -r "$HERE/scripts/checks" "$work/scripts/checks"
echo "- [ghost](skills/engineering/ghost/SKILL.md)" > "$work/README.md"
out="$(bash "$work/scripts/checks/readme-links.sh" 2>&1)"; st=$?
if [[ $st -ne 0 ]] && grep -qF "ghost/SKILL.md linked in README but file not found" <<< "$out"; then
  ok "readme-links fails alone with its message"
else
  bad "readme-links standalone: status $st"
fi

if [[ $failures -eq 0 ]]; then
  echo "All check tests passed."
else
  echo "$failures check test(s) failed." >&2
  exit 1
fi
