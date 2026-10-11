#!/usr/bin/env bash
# Check: stale-translation (runs alone or under scripts/validate.sh).
# A pt-BR file whose marker differs from the hash of its English source is
# stale. Files with no marker yet are skipped (add one with
# scripts/translation-marker.sh refresh), as are skills with no translation.
set -uo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

echo "==> pt-BR translations match the English they were aligned with"
_checked=0
while IFS= read -r _f; do
  _src="$(translation_source "$_f")"
  [[ -n "$_src" ]] || continue
  _rec="$(recorded_hash "$_f")"
  [[ -n "$_rec" ]] || continue
  _checked=$((_checked + 1))
  if [[ ! -f "$_src" ]]; then
    fail "${_f#"$REPO/"} is stale: source ${_src#"$REPO/"} not found"
  elif [[ "$_rec" != "$(source_hash "$_src")" ]]; then
    fail "${_f#"$REPO/"} is stale: ${_src#"$REPO/"} changed since it was aligned (review, then: bash scripts/translation-marker.sh refresh ${_f#"$REPO/"})"
  fi
done < <(find "$SKILLS_DIR" \( -name 'TRADUCAO.pt-BR.md' -o -name 'RESUMO.md' -o -name '*.pt-BR.md' \) | sort -u)
[[ $errors -eq 0 ]] && pass "$_checked marked translation(s) up to date"

finish
