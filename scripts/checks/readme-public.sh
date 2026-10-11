#!/usr/bin/env bash
# Check: readme-public (runs alone or under scripts/validate.sh).
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# ── 2. Public skills listed in root README ────────────────────────────────────
echo "==> Public skills referenced in root README.md"
for bucket in "${PUBLIC_BUCKETS[@]}"; do
  bucket_dir="$SKILLS_DIR/$bucket"
  [[ -d "$bucket_dir" ]] || continue
  for skill_dir in "$bucket_dir"/*/; do
    [[ -f "$skill_dir/SKILL.md" ]] || continue
    skill_name="$(basename "$skill_dir")"
    rel_path="skills/$bucket/$skill_name/SKILL.md"
    if is_unpromoted "$skill_name"; then
      if grep -qF "$rel_path" "$README"; then
        fail "$bucket/$skill_name is unpromoted but appears in README"
      else
        pass "$bucket/$skill_name not in README (unpromoted, correct)"
      fi
    elif grep -qF "$rel_path" "$README"; then
      pass "$bucket/$skill_name in README"
    else
      fail "$bucket/$skill_name not referenced in README (expected path: $rel_path)"
    fi
  done
done

finish
