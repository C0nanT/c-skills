#!/usr/bin/env bash
# Check: setup-skills-merge (runs alone or under scripts/validate.sh).
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

# ── 10. setup-skills settings merge snippet ───────────────────────────────────
# Extracts the bash block that starts with the marker comment below, plus the
# `text` deny list right before it, and runs the snippet against throwaway
# settings files. CLAUDE_PROJECT_DIR is pinned to the temp dir on every run so
# a session's own project settings are never touched.
echo "==> setup-skills settings merge snippet"
SETUP_SKILL="$SKILLS_DIR/engineering/setup-skills/SKILL.md"
MERGE_MARKER="# setup-skills: merge git deny rules"
_merge_tmp="$(mktemp -d)"
trap 'rm -rf "$_merge_tmp"' EXIT

awk -v marker="$MERGE_MARKER" '
  /^```bash$/ { getline first; if (first == marker) { grab = 1; print first }; next }
  grab && /^```$/ { exit }
  grab { print }
' "$SETUP_SKILL" > "$_merge_tmp/snippet.sh"

# The deny list text block is the last ```text block before the snippet.
awk -v marker="$MERGE_MARKER" '
  /^```text$/ { inblock = 1; n = 0; next }
  inblock && /^```$/ { inblock = 0; next }
  inblock { lines[++n] = $0; next }
  $0 == marker { for (i = 1; i <= n; i++) print lines[i]; exit }
' "$SETUP_SKILL" > "$_merge_tmp/deny-list.txt"

run_merge() { # $1 = project dir, $2 = PATH for the run
  env PATH="$2" CLAUDE_PROJECT_DIR="$1" "$bash_bin" "$_merge_tmp/snippet.sh" \
    > "$1/out.log" 2>&1
}

if [[ ! -s "$_merge_tmp/snippet.sh" ]]; then
  fail "setup-skills: merge snippet not found (marker: $MERGE_MARKER)"
elif [[ ! -s "$_merge_tmp/deny-list.txt" ]]; then
  fail "setup-skills: deny list text block not found before the merge snippet"
else
  bash_bin="$(command -v bash)"
  # Every `git <cmd> *` rule for these three must have both -C shapes.
  for cmd in push "reset --hard" clean; do
    for rule in "Bash(git -C * $cmd)" "Bash(git -C * $cmd *)"; do
      if grep -qxF "$rule" "$_merge_tmp/deny-list.txt"; then
        pass "setup-skills deny list has $rule"
      else
        fail "setup-skills deny list missing $rule"
      fi
    done
  done

  # a. No jq on PATH: exits non-zero, existing file byte-identical.
  d="$_merge_tmp/nojq"; mkdir -p "$d/.claude" "$d/bin"
  echo '{"permissions":{"allow":["Bash(ls *)"]}}' > "$d/.claude/settings.json"
  cp "$d/.claude/settings.json" "$d/orig.json"
  if env PATH="$d/bin" CLAUDE_PROJECT_DIR="$d" "$bash_bin" "$_merge_tmp/snippet.sh" > "$d/out.log" 2>&1; then
    fail "setup-skills merge: exited 0 without jq"
  elif ! cmp -s "$d/orig.json" "$d/.claude/settings.json"; then
    fail "setup-skills merge: settings.json changed without jq"
  else
    pass "setup-skills merge: stops without jq, file untouched"
  fi

  # b. Invalid JSON: exits non-zero, prints an error, file untouched.
  d="$_merge_tmp/invalid"; mkdir -p "$d/.claude"
  printf '{ "permissions": { "allow": [ "Bash(ls *)" ' > "$d/.claude/settings.json"
  cp "$d/.claude/settings.json" "$d/orig.json"
  if run_merge "$d" "$PATH"; then
    fail "setup-skills merge: exited 0 on invalid JSON"
  elif ! cmp -s "$d/orig.json" "$d/.claude/settings.json"; then
    fail "setup-skills merge: invalid settings.json was modified"
  elif [[ ! -s "$d/out.log" ]]; then
    fail "setup-skills merge: no error shown on invalid JSON"
  elif compgen -G "$d/.claude/settings.json.*" > /dev/null; then
    fail "setup-skills merge: left temp or backup files on invalid JSON"
  else
    pass "setup-skills merge: stops on invalid JSON, file untouched"
  fi

  # c. Valid settings: allow/hooks/env/existing deny kept, rules appended, backup made.
  d="$_merge_tmp/valid"; mkdir -p "$d/.claude"
  cat > "$d/.claude/settings.json" <<'JSON'
{
  "permissions": {
    "allow": ["Bash(npm test *)", "Read(./src/**)"],
    "deny": ["Read(./.env)"]
  },
  "hooks": {"PostToolUse": [{"matcher": "Edit", "hooks": [{"type": "command", "command": "echo hi"}]}]},
  "env": {"FOO": "bar"}
}
JSON
  cp "$d/.claude/settings.json" "$d/orig.json"
  if ! run_merge "$d" "$PATH"; then
    fail "setup-skills merge: failed on valid settings: $(cat "$d/out.log")"
  else
    s="$d/.claude/settings.json"
    if jq -e --slurpfile o "$d/orig.json" '
        .permissions.allow == $o[0].permissions.allow
        and .hooks == $o[0].hooks and .env == $o[0].env
        and .permissions.deny[0] == "Read(./.env)"' "$s" > /dev/null; then
      pass "setup-skills merge: allow rules, hooks, env and existing deny kept"
    else
      fail "setup-skills merge: existing settings not preserved"
    fi
    missing="$(jq -r --rawfile want "$_merge_tmp/deny-list.txt" '
        .permissions.deny as $d
        | $want | split("\n") | map(select(length > 0))
        | map(select(. as $r | $d | index([$r]) | not)) | .[]' "$s")"
    if [[ -z "$missing" ]]; then
      pass "setup-skills merge: every rule of the text list is in deny (lists in sync)"
    else
      fail "setup-skills merge: rules in the text list missing after merge: $missing"
    fi
    backups=("$d/.claude/settings.json.bak-"*)
    if [[ ${#backups[@]} -eq 1 && -f "${backups[0]}" ]] && cmp -s "${backups[0]}" "$d/orig.json"; then
      pass "setup-skills merge: backup equals the previous file"
    else
      fail "setup-skills merge: expected one backup identical to the previous file"
    fi

    # d. Second run: no duplicates, no change, no new backup.
    cp "$s" "$d/after1.json"
    if run_merge "$d" "$PATH" && cmp -s "$s" "$d/after1.json" \
        && jq -e '(.permissions.deny | length) == (.permissions.deny | unique | length)' "$s" > /dev/null \
        && [[ $(compgen -G "$d/.claude/settings.json.bak-*" | wc -l) -eq 1 ]]; then
      pass "setup-skills merge: second run is a no-op, no duplicates"
    else
      fail "setup-skills merge: second run changed the file or duplicated rules"
    fi
  fi

  # e. Missing file and empty file: created with the deny rules.
  for kind in missing empty; do
    d="$_merge_tmp/$kind"; mkdir -p "$d"
    if [[ "$kind" == empty ]]; then mkdir -p "$d/.claude"; : > "$d/.claude/settings.json"; fi
    want="$(grep -c . "$_merge_tmp/deny-list.txt")"
    if run_merge "$d" "$PATH" \
        && jq -e --argjson n "$want" '(.permissions.deny | length) == $n' "$d/.claude/settings.json" > /dev/null; then
      pass "setup-skills merge: $kind settings.json created with the deny rules"
    else
      fail "setup-skills merge: $kind settings.json not created with the deny rules"
    fi
  done
fi

finish
