#!/usr/bin/env bash
# Print or refresh the alignment marker of a pt-BR file.
#   scripts/translation-marker.sh print   <file>   show the marker for the current English source
#   scripts/translation-marker.sh refresh <file>   write it (replacing any old one) after reviewing the translation
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/checks/lib.sh"

cmd="${1:-}"; file="${2:-}"
[[ ( "$cmd" == print || "$cmd" == refresh ) && -f "$file" ]] \
  || { echo "usage: $0 print|refresh <translation-file>" >&2; exit 2; }
src="$(translation_source "$file")"
[[ -n "$src" && -f "$src" ]] \
  || { echo "no English source found for $file" >&2; exit 2; }
marker="<!-- aligned-with: sha256:$(source_hash "$src") -->"

if [[ "$cmd" == print ]]; then
  echo "$marker"
else
  body="$(grep -vE "$MARKER_RE" "$file" || true)"
  # $(...) drops trailing newlines, so the marker lands one blank line after the text.
  printf '%s\n\n%s\n' "$body" "$marker" > "$file"
  echo "refreshed $file"
fi
