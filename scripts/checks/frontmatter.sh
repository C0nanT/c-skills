#!/usr/bin/env bash
# Check: frontmatter (runs alone or under scripts/validate.sh).
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# ── 1. Frontmatter ────────────────────────────────────────────────────────────
echo "==> Frontmatter (name + description required)"
while IFS= read -r skill_file; do
  rel="${skill_file#"$REPO/"}"
  has_name=$(grep -m1 '^name:' "$skill_file" || true)
  has_desc=$(grep -m1 '^description' "$skill_file" || true)
  if [[ -z "$has_name" || -z "$has_desc" ]]; then
    fail "$rel missing name or description in frontmatter"
  else
    pass "$rel"
  fi
done < <(find "$SKILLS_DIR" -name "SKILL.md" | sort)

finish
