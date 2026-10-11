#!/usr/bin/env bash
# Check: untrusted-data (runs alone or under scripts/validate.sh).
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# ── Third-party text is data ─────────────────────────────────────────────────
# The skills that read text written by someone else (MR, remote issue, web
# page) carry one identical sentence, so the rule reads the same everywhere and
# can be copied into skills of other buckets.
echo "==> Untrusted-data sentence in skills that read third-party text"
for skill in review-mr review-axes research; do
  f="$SKILLS_DIR/engineering/$skill/SKILL.md"
  if grep -qF "$UNTRUSTED_SENTENCE" "$f"; then
    pass "$skill carries the untrusted-data sentence"
  else
    fail "$skill: missing the untrusted-data sentence (copy it verbatim from scripts/checks/lib.sh)"
  fi
done

finish
