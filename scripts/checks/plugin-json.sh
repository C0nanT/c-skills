#!/usr/bin/env bash
# Check: plugin-json (runs alone or under scripts/validate.sh).
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# ── 6. plugin.json consistency ───────────────────────────────────────────────
PLUGIN_JSON="$REPO/.claude-plugin/plugin.json"
echo "==> plugin.json ↔ disk consistency"

if [[ ! -f "$PLUGIN_JSON" ]]; then
  fail "$PLUGIN_JSON not found"
else
  # 6a. plugin.json → disk: every listed path must have a SKILL.md
  while IFS= read -r skill_path; do
    # paths in plugin.json are relative to the repo root (e.g. "./skills/engineering/foo")
    clean_path="${skill_path#./}"
    full_dir="$REPO/$clean_path"
    if [[ ! -d "$full_dir" ]]; then
      fail "plugin.json: $skill_path: directory not found on disk"
    elif [[ ! -f "$full_dir/SKILL.md" ]]; then
      fail "plugin.json: $skill_path: SKILL.md not found"
    else
      pass "plugin.json → disk: $skill_path"
    fi
  done < <(jq -r '.skills[]' "$PLUGIN_JSON")

  # 6b. disk → plugin.json: public skills must appear; private must not
  plugin_paths="$(jq -r '.skills[]' "$PLUGIN_JSON")"

  for bucket in "${PUBLIC_BUCKETS[@]}"; do
    bucket_dir="$SKILLS_DIR/$bucket"
    [[ -d "$bucket_dir" ]] || continue
    for skill_dir in "$bucket_dir"/*/; do
      [[ -f "$skill_dir/SKILL.md" ]] || continue
      skill_name="$(basename "$skill_dir")"
      expected_path="./skills/$bucket/$skill_name"
      if is_unpromoted "$skill_name"; then
        if echo "$plugin_paths" | grep -qxF "$expected_path"; then
          fail "plugin.json: unpromoted skill must not appear: $expected_path"
        else
          pass "disk → plugin.json: $bucket/$skill_name absent (unpromoted, correct)"
        fi
      elif echo "$plugin_paths" | grep -qxF "$expected_path"; then
        pass "disk → plugin.json: $bucket/$skill_name present (public)"
      else
        fail "plugin.json: missing public skill: $expected_path"
      fi
    done
  done

  for bucket in "${PRIVATE_BUCKETS[@]}"; do
    bucket_dir="$SKILLS_DIR/$bucket"
    [[ -d "$bucket_dir" ]] || continue
    for skill_dir in "$bucket_dir"/*/; do
      [[ -f "$skill_dir/SKILL.md" ]] || continue
      skill_name="$(basename "$skill_dir")"
      expected_path="./skills/$bucket/$skill_name"
      if echo "$plugin_paths" | grep -qxF "$expected_path"; then
        fail "plugin.json: private skill must not appear: $expected_path"
      else
        pass "disk → plugin.json: $bucket/$skill_name absent (private, correct)"
      fi
    done
  done
fi

finish
