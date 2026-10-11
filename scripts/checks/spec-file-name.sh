#!/usr/bin/env bash
# Check: spec-file-name (runs alone or under scripts/validate.sh).
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# ── 12. Spec file name ────────────────────────────────────────────────────────
# The spec is `SPEC.md` everywhere. A lowercase `spec.md` in the engineering
# skills or in this repo's tracker doc means a skill looks for a file the
# to-spec skill never writes.
echo "==> Spec file name (SPEC.md, never spec.md)"
_spec_hits="$(grep -rnP '(?<![\w./-])spec\.md\b' "$SKILLS_DIR/engineering" "$REPO/docs/agents/issue-tracker.md" 2>/dev/null || true)"
if [[ -z "$_spec_hits" ]]; then
  pass "no lowercase spec.md in engineering skills or docs/agents/issue-tracker.md"
else
  while IFS= read -r _hit; do
    fail "lowercase spec.md (use SPEC.md): ${_hit#"$REPO/"}"
  done <<< "$_spec_hits"
fi

finish
