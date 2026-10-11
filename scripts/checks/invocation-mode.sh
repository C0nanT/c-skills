#!/usr/bin/env bash
# Check: invocation-mode (runs alone or under scripts/validate.sh).
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# ── 9. Invocation mode ───────────────────────────────────────────────────────
# A skill is user-invoked in both harnesses or neither: SKILL.md carries
# `disable-model-invocation: true` exactly when agents/openai.yaml carries
# `allow_implicit_invocation: false`. Every skill has an openai.yaml, and a
# `Skill tool ... "name"` call must name a skill that exists and is model-invoked.
echo "==> Invocation mode (SKILL.md ↔ openai.yaml, Skill tool targets)"
declare -A user_invoked=()
declare -A skill_exists=()
while IFS= read -r skill_file; do
  skill_dir="$(dirname "$skill_file")"
  skill_name="$(basename "$skill_dir")"
  rel="${skill_file#"$REPO/"}"
  skill_exists[$skill_name]=1
  yaml="$skill_dir/agents/openai.yaml"
  md_user=0; yaml_user=0
  # Only the frontmatter block (up to the second ---) counts.
  if awk 'NR==1 {next} $0=="---" {exit} /^disable-model-invocation: true$/ {f=1} END {exit !f}' "$skill_file"; then
    md_user=1
  fi
  [[ $md_user -eq 1 ]] && user_invoked[$skill_name]=1
  if [[ ! -f "$yaml" ]]; then
    fail "$rel: agents/openai.yaml missing"
    continue
  fi
  grep -qE '^[[:space:]]+allow_implicit_invocation: false$' "$yaml" && yaml_user=1
  if [[ $md_user -ne $yaml_user ]]; then
    fail "$rel: invocation mode differs (SKILL.md user-invoked=$md_user, openai.yaml user-invoked=$yaml_user)"
  else
    pass "$rel: invocation mode consistent"
  fi
done < <(find "$SKILLS_DIR" -name "SKILL.md" | sort)

while IFS= read -r skill_file; do
  rel="${skill_file#"$REPO/"}"
  while IFS= read -r target; do
    [[ -z "$target" ]] && continue
    if [[ -z "${skill_exists[$target]:-}" ]]; then
      fail "$rel: Skill tool call names \"$target\", which does not exist"
    elif [[ -n "${user_invoked[$target]:-}" ]]; then
      fail "$rel: Skill tool call names \"$target\", which is user-invoked"
    else
      pass "$rel: Skill tool call to $target"
    fi
  done < <(grep -oE 'Skill tool[^."]*("[a-z][a-z0-9-]*"( and )?)+' "$skill_file" | grep -oE '"[a-z][a-z0-9-]*"' | tr -d '"' | sort -u)
done < <(find "$SKILLS_DIR" -name "SKILL.md" | sort)

finish
