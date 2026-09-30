#!/bin/sh

set -eu

source_pane=${HERDR_ACTIVE_PANE_ID:-${HERDR_PANE_ID:-}}
herdr_bin=${HERDR_BIN_PATH:-}

if [ -z "$source_pane" ]; then
  printf 'herdr new-main: active pane ID not found\n' >&2
  exit 1
fi

if [ -z "$herdr_bin" ]; then
  herdr_bin=$(command -v herdr 2>/dev/null || true)
fi

if [ -z "$herdr_bin" ] && [ -x "$HOME/.local/bin/herdr" ]; then
  herdr_bin=$HOME/.local/bin/herdr
fi

if [ -z "$herdr_bin" ]; then
  printf 'herdr new-main: herdr executable not found\n' >&2
  exit 127
fi

split_result=$("$herdr_bin" pane split \
  --pane "$source_pane" \
  --direction right \
  --ratio 0.67 \
  --focus)

new_pane=$(printf '%s\n' "$split_result" | sed -n 's/.*"pane_id"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p')

if [ -z "$new_pane" ]; then
  printf 'herdr new-main: could not read the new pane ID\n' >&2
  exit 1
fi

"$herdr_bin" pane swap --source-pane "$new_pane" --target-pane "$source_pane" >/dev/null
