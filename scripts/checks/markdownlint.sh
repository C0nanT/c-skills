#!/usr/bin/env bash
# Check: markdownlint (runs alone or under scripts/validate.sh).
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# ── 8. Markdownlint ──────────────────────────────────────────────────────────
echo "==> Markdownlint (SKILL.md, README.md, REFERENCE.md)"
mapfile -t _md_files < <(find "$REPO" \( -name "SKILL.md" -o -name "README.md" -o -name "REFERENCE.md" \) | sort)
if [[ ${#_md_files[@]} -gt 0 ]]; then
  _lint_errors=0
  while IFS= read -r _line; do
    [[ -z "$_line" ]] && continue
    fail "markdownlint: $_line"
    ((_lint_errors++)) || true
  done < <(npx --yes markdownlint-cli "${_md_files[@]}" 2>&1 | grep -v '^npm ' | grep -v '^$')
  [[ $_lint_errors -eq 0 ]] && pass "all markdown files"
fi

finish
