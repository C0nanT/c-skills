#!/usr/bin/env bash
# Check: wizard-write-env (runs alone or under scripts/validate.sh).
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

_merge_tmp="$(mktemp -d)"
trap 'rm -rf "$_merge_tmp"' EXIT

# ── 11. wizard library protects secrets ───────────────────────────────────────
# Extracts the wizard library (everything above the `# STAGES:` marker of
# template.sh) and runs write_env in throwaway git repos. stdin is scripted:
# the first answer is "add to .gitignore?", the second "write anyway?".
echo "==> wizard write_env checks ENV_FILE is gitignored"
WIZARD_TEMPLATE="$SKILLS_DIR/engineering/wizard/template.sh"
_wiz_tmp="$_merge_tmp/wizard"; mkdir -p "$_wiz_tmp"
awk '/^# STAGES:/ { exit } { print }' "$WIZARD_TEMPLATE" > "$_wiz_tmp/lib.sh"

if ! grep -q 'write_env()' "$_wiz_tmp/lib.sh"; then
  fail "wizard: library not found above the '# STAGES:' marker in template.sh"
else
  run_wizard() { # $1 = repo dir, $2 = scripted stdin
    (cd "$1" && printf '%s' "$2" | bash -c 'source "$1"; write_env API_KEY s3cret' _ "$_wiz_tmp/lib.sh") \
      > "$1/out.log" 2>&1
  }
  new_repo() { rm -rf "$1"; mkdir -p "$1"; git -C "$1" init -q; }

  # a. Not ignored, declines both questions: nothing is written.
  d="$_wiz_tmp/declined"; new_repo "$d"
  if run_wizard "$d" $'n\nn\n'; then
    fail "wizard: write_env succeeded after the user declined"
  elif [[ -e "$d/.env" ]]; then
    fail "wizard: wrote .env without confirmation while it is not gitignored"
  else
    pass "wizard: unignored .env, declined: nothing written"
  fi

  # b. Not ignored, accepts adding it: ignored, then written.
  d="$_wiz_tmp/add"; new_repo "$d"
  if run_wizard "$d" $'y\n' && git -C "$d" check-ignore -q .env \
      && grep -qx "API_KEY='s3cret'" "$d/.env"; then
    pass "wizard: unignored .env, accepted: added to .gitignore then written"
  else
    fail "wizard: accepting the .gitignore offer did not ignore and write .env"
  fi

  # b2. Existing .gitignore without a trailing newline: entry must not merge into the last line.
  d="$_wiz_tmp/nonewline"; new_repo "$d"; printf 'node_modules' > "$d/.gitignore"
  if run_wizard "$d" $'y\n' && git -C "$d" check-ignore -q .env \
      && grep -qx 'node_modules' "$d/.gitignore"; then
    pass "wizard: .gitignore without trailing newline: entry appended on its own line"
  else
    fail "wizard: appending to a .gitignore without trailing newline merged the entry into the last line"
  fi

  # c. Not ignored, declines the offer but confirms writing anyway.
  d="$_wiz_tmp/anyway"; new_repo "$d"
  if run_wizard "$d" $'n\ny\n' && grep -qx "API_KEY='s3cret'" "$d/.env" \
      && ! git -C "$d" check-ignore -q .env; then
    pass "wizard: unignored .env, confirmed writing anyway: written, .gitignore untouched"
  else
    fail "wizard: explicit confirmation to write anyway did not write .env"
  fi

  # d. Already ignored: no question at all (empty stdin would answer "no").
  d="$_wiz_tmp/ignored"; new_repo "$d"; echo '.env' > "$d/.gitignore"
  if run_wizard "$d" '' && grep -qx "API_KEY='s3cret'" "$d/.env" \
      && ! grep -q '\[y/N\]' "$d/out.log"; then
    pass "wizard: already-ignored .env: written with no extra question"
  else
    fail "wizard: asked a question or failed although .env is already gitignored"
  fi
fi

finish
