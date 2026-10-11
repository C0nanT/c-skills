#!/usr/bin/env bash
# Check: bucket-readme-disk (runs alone or under scripts/validate.sh).
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# ── 7. Bucket README ↔ disk consistency ──────────────────────────────────────
echo "==> Bucket README.md ↔ disk consistency"
for bucket in "${PUBLIC_BUCKETS[@]}" "${PRIVATE_BUCKETS[@]}"; do
  bucket_dir="$SKILLS_DIR/$bucket"
  bucket_readme="$bucket_dir/README.md"
  [[ -d "$bucket_dir" ]] || continue
  [[ -f "$bucket_readme" ]] || continue  # check 5 already reports missing READMEs

  # 7a. disk → README: every SKILL.md on disk must be linked in bucket README
  for skill_dir in "$bucket_dir"/*/; do
    [[ -f "$skill_dir/SKILL.md" ]] || continue
    skill_name="$(basename "$skill_dir")"
    rel_link="./$skill_name/SKILL.md"
    if grep -qF "$rel_link" "$bucket_readme"; then
      pass "$bucket/README.md links $rel_link"
    else
      fail "skills/$bucket/README.md: missing link for $rel_link (skill exists on disk)"
    fi
  done

  # 7b. README → disk: every linked SKILL.md path must exist on disk
  while IFS= read -r linked; do
    # linked is like ./skill-name/SKILL.md; resolve against bucket_dir
    full_path="$bucket_dir/${linked#./}"
    if [[ -f "$full_path" ]]; then
      pass "$bucket/README.md: $linked exists on disk"
    else
      fail "skills/$bucket/README.md: links $linked but file not found on disk"
    fi
  done < <(grep -oE '\./[^/]+/SKILL\.md' "$bucket_readme" | sort -u)
done

finish
