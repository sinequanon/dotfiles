#!/usr/bin/env bash
set -euo pipefail

label=${1-}

if [[ -z "$label" ]]; then
  tmux set-option -p @pane_label ''
  tmux set-option -pu @pane_label_source 2>/dev/null || true
  tmux display-message 'Pane label cleared'
else
  tmux set-option -p @pane_label "$label"
  tmux set-option -p @pane_label_source manual
  tmux display-message "Pane label: $label"
fi
