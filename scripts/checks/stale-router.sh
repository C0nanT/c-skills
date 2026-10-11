#!/usr/bin/env bash
# Check: stale-router (runs alone or under scripts/validate.sh).
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# ── Stale router facts ───────────────────────────────────────────────────────
echo "==> No upstream issues/ path in engineering skills, no /diagnosing-bugs in ask-skills"
_issues_hits="$(grep -rnE '\.scratch/<[^>]*>/issues/' "$SKILLS_DIR/engineering" 2>/dev/null || true)"
if [[ -z "$_issues_hits" ]]; then
  pass "no .scratch/<...>/issues/ in engineering skills"
else
  while IFS= read -r _hit; do
    fail "upstream issues/ path (use tickets/): ${_hit#"$REPO/"}"
  done <<< "$_issues_hits"
fi
_diag_hits="$(grep -n '/diagnosing-bugs' "$SKILLS_DIR/engineering/ask-skills/SKILL.md" 2>/dev/null || true)"
if [[ -z "$_diag_hits" ]]; then
  pass "ask-skills does not route to /diagnosing-bugs"
else
  while IFS= read -r _hit; do
    fail "ask-skills routes to unpromoted /diagnosing-bugs: $_hit"
  done <<< "$_diag_hits"
fi

finish
