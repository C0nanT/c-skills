#!/usr/bin/env bash
# Check: readme-private (runs alone or under scripts/validate.sh).
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# ── 3. Private skills NOT in root README ─────────────────────────────────────
echo "==> Private skills absent from root README.md"
for bucket in "${PRIVATE_BUCKETS[@]}"; do
  bucket_dir="$SKILLS_DIR/$bucket"
  [[ -d "$bucket_dir" ]] || continue
  for skill_dir in "$bucket_dir"/*/; do
    [[ -f "$skill_dir/SKILL.md" ]] || continue
    skill_name="$(basename "$skill_dir")"
    rel_path="skills/$bucket/$skill_name/SKILL.md"
    if grep -qF "$rel_path" "$README"; then
      fail "$bucket/$skill_name is private but appears in README"
    else
      pass "$bucket/$skill_name not in README (correct)"
    fi
  done
done

finish
