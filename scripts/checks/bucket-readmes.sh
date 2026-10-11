#!/usr/bin/env bash
# Check: bucket-readmes (runs alone or under scripts/validate.sh).
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# ── 5. Bucket READMEs exist ───────────────────────────────────────────────────
echo "==> Bucket README.md files exist"
for bucket in "${PUBLIC_BUCKETS[@]}" "${PRIVATE_BUCKETS[@]}"; do
  bucket_dir="$SKILLS_DIR/$bucket"
  [[ -d "$bucket_dir" ]] || continue
  if [[ -f "$bucket_dir/README.md" ]]; then
    pass "$bucket/README.md"
  else
    fail "$bucket/README.md missing"
  fi
done

finish
