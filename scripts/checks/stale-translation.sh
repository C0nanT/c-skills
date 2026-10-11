#!/usr/bin/env bash
# Check: stale-translation (runs alone or under scripts/validate.sh).
# A pt-BR file whose marker differs from the hash of its English source is
# stale, and one with no marker at all fails too (add it with
# scripts/translation-marker.sh refresh). Skills with no translation are
# ignored. Process spawns are constant: one find, one grep over every
# translation, one sha256sum over every source.
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

echo "==> pt-BR translations match the English they were aligned with"

files=()
while IFS= read -r _f; do files+=("$_f"); done < <(
  find "$SKILLS_DIR" \( -name 'TRADUCAO.pt-BR.md' -o -name 'RESUMO.md' -o -name '*.pt-BR.md' \) | sort -u)

# Recorded marker per translation (the last one in the file wins).
declare -A recorded=()
if [[ ${#files[@]} -gt 0 ]]; then
  while IFS= read -r _line; do
    _hash="${_line##*sha256:}"; _hash="${_hash%% *}"
    _path="${_line%%:<!-- aligned-with:*}"
    recorded["$_path"]="$_hash"
  done < <(grep -HE "$MARKER_RE" "${files[@]}" || true)
fi

# English source per translation, then one sha256sum over the ones that exist.
declare -A source_of=() actual=()
_existing=()
for _f in "${files[@]}"; do
  _dir="${_f%/*}"; _base="${_f##*/}"
  case "$_base" in
    TRADUCAO.pt-BR.md|RESUMO.md) _src="$_dir/SKILL.md" ;;
    *) _src="$_dir/${_base%.pt-BR.md}.md" ;;
  esac
  source_of["$_f"]="$_src"
  if [[ -f "$_src" && -z "${actual[$_src]+x}" ]]; then
    actual["$_src"]=""
    _existing+=("$_src")
  fi
done
if [[ ${#_existing[@]} -gt 0 ]]; then
  while IFS= read -r _line; do
    actual["${_line#*  }"]="${_line%% *}"
  done < <(sha256sum "${_existing[@]}")
fi

for _f in "${files[@]}"; do
  _src="${source_of[$_f]}"
  _rel="${_f#"$REPO/"}"
  if [[ -z "${recorded[$_f]:-}" ]]; then
    fail "$_rel has no aligned-with marker, run: bash scripts/translation-marker.sh refresh $_rel"
  elif [[ ! -f "$_src" ]]; then
    fail "$_rel is stale: source ${_src#"$REPO/"} not found"
  elif [[ "${recorded[$_f]}" != "${actual[$_src]}" ]]; then
    fail "$_rel is stale: ${_src#"$REPO/"} changed since it was aligned (review, then: bash scripts/translation-marker.sh refresh $_rel)"
  fi
done
[[ $errors -eq 0 ]] && pass "${#files[@]} translation(s) up to date"

finish
