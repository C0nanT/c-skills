#!/usr/bin/env bash
# Fixture harness for scripts/validate.sh. Builds a minimal valid repo in a temp
# dir, runs the validator copied into it, and asserts only exit code and message.
# Usage: bash tests/validate-fixture.sh
set -uo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

failures=0
ok() { echo "  ok:   $*"; }
bad() { echo "  FAIL: $*" >&2; failures=$((failures + 1)); }

SENTENCE="$(grep -m1 -oP "^UNTRUSTED_SENTENCE='\K[^']+(?=')" "$HERE/scripts/validate.sh")"
SKILLS=(alpha review-mr review-axes research setup-skills wizard)

write_skill() { # $1 = repo, $2 = name
  local dir="$1/skills/engineering/$2"
  mkdir -p "$dir/agents"
  printf -- '---\nname: %s\ndescription: Fixture skill %s. Use when testing.\n---\n\n# %s\n\n%s\n' \
    "$2" "$2" "$2" "$SENTENCE" > "$dir/SKILL.md"
  printf 'policy:\n  allow_implicit_invocation: true\n' > "$dir/agents/openai.yaml"
}

build_fixture() { # $1 = repo dir
  local r="$1" s
  mkdir -p "$r/scripts" "$r/.claude-plugin"
  cp "$HERE/scripts/validate.sh" "$r/scripts/validate.sh"
  cp "$HERE/.markdownlint.jsonc" "$r/.markdownlint.jsonc"
  for s in alpha review-mr review-axes research; do
    write_skill "$r" "$s"
  done
  # setup-skills and wizard are exercised by path (merge snippet, template.sh),
  # so the fixture takes the real files.
  mkdir -p "$r/skills/engineering/setup-skills" "$r/skills/engineering/wizard"
  cp -r "$HERE/skills/engineering/setup-skills/." "$r/skills/engineering/setup-skills/"
  cp -r "$HERE/skills/engineering/wizard/." "$r/skills/engineering/wizard/"
  {
    echo "# Fixture"; echo
    for s in "${SKILLS[@]}"; do
      echo "- [$s](./skills/engineering/$s/SKILL.md)"
    done
  } > "$r/README.md"
  {
    echo "# Engineering"; echo
    for s in "${SKILLS[@]}"; do
      echo "- [$s](./$s/SKILL.md)"
    done
  } > "$r/skills/engineering/README.md"
  printf '%s\n' "${SKILLS[@]}" \
    | jq -R '"./skills/engineering/" + .' \
    | jq -s '{name: "fixture", skills: .}' > "$r/.claude-plugin/plugin.json"
}

run_validate() { # $1 = repo dir; sets status and output
  output="$(bash "$1/scripts/validate.sh" 2>&1)"
  status=$?
}

echo "==> minimal valid fixture passes"
good="$WORK/good"; mkdir -p "$good"; build_fixture "$good"
run_validate "$good"
if [[ $status -eq 0 ]] && grep -q "All checks passed." <<< "$output"; then
  ok "exit 0 and 'All checks passed.'"
else
  bad "expected exit 0, got $status"; grep FAIL <<< "$output" >&2
fi

echo "==> fixture with a broken README link fails"
broken="$WORK/broken"; mkdir -p "$broken"; build_fixture "$broken"
echo "- [ghost](./skills/engineering/ghost/SKILL.md)" >> "$broken/README.md"
run_validate "$broken"
if [[ $status -ne 0 ]] \
    && grep -qF "skills/engineering/ghost/SKILL.md linked in README but file not found" <<< "$output"; then
  ok "non-zero exit and the broken-link message"
else
  bad "expected non-zero exit with broken-link message, got $status"; grep FAIL <<< "$output" >&2
fi

if [[ $failures -eq 0 ]]; then
  echo "All fixture tests passed."
else
  echo "$failures fixture test(s) failed." >&2
  exit 1
fi
