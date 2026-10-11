#!/usr/bin/env bash
# Check: readme-links (runs alone or under scripts/validate.sh).
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# ── 4. README links point to existing files ───────────────────────────────────
echo "==> README links resolve to existing files"
while IFS= read -r link_path; do
  full_path="$REPO/$link_path"
  if [[ -f "$full_path" ]]; then
    pass "$link_path"
  else
    fail "$link_path linked in README but file not found"
  fi
done < <(grep -oE 'skills/[^)]+/SKILL\.md' "$README" | sort -u)

finish
