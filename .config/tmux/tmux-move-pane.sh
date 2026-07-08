#!/usr/bin/env bash
# tmux-move-pane.sh — move the focused pane to the left/right column WITHOUT
# swapping it with whatever is there. The pane(s) it leaves behind reflow to
# fill the vacated space (tmux does this automatically when a pane is removed
# from a split).
#
#   tmux-move-pane.sh <left|right> <below|above> [<pane_id>]
#
# Behavior:
#   • If a column already exists on that side (the focused pane has a neighbor
#     there), the pane is STACKED into that column — below the adjacent pane
#     (default) or above it ("above").
#   • If the focused pane already touches that edge (nothing beside it), it
#     becomes a new FULL-HEIGHT column on that side; the remaining pane(s) fill
#     the rest of the window.
#
# Bound (no prefix) in .tmux.conf — comma key = left, period key = right,
# Shift = land on top:
#   M-,  left  below     M-<  left  above
#   M-.  right below     M->  right above
#
# Mechanics (verified): join-pane moves a pane out of its current split (so its
# old siblings expand to fill) and into a split of the target pane.
#   -v          stack (source below target)        -b  place source "before"
#   -h          side by side                            (above for -v, left for -h)
#   -f          new pane spans the FULL window dimension, not just the target's
#   {left-of}/{right-of}  the pane adjacent to the active pane in that direction
set -euo pipefail

dir="${1:?usage: tmux-move-pane.sh <left|right> <below|above> [pane_id]}"
place="${2:-below}"
src="${3:-}"

# Source pane: explicit arg (passed as #{pane_id} from the binding) or the
# active pane as a fallback.
[ -z "$src" ] && src="$(tmux display-message -p '#{pane_id}')"

case "$dir" in
  left)  edge_fmt='#{pane_at_left}';  neighbor='{left-of}';  newcol_before=1 ;;
  right) edge_fmt='#{pane_at_right}'; neighbor='{right-of}'; newcol_before=0 ;;
  *) printf 'tmux-move-pane: dir must be left|right (got %s)\n' "$dir" >&2; exit 2 ;;
esac

# Make the source pane active so the relative {left-of}/{right-of} target and
# the edge test resolve against it. (It is normally already active — the binding
# fires on the focused pane — so this is just a safety belt and a no-op visually.)
tmux select-pane -t "$src" 2>/dev/null || exit 0

at_edge="$(tmux display-message -p -t "$src" "$edge_fmt")"

# -b on join-pane means "place the source before the target": with -v that is
# ABOVE the neighbor; with the -h full-height fallback that is the LEFT side.
above_flag=''
[ "$place" = "above" ] && above_flag='-b'

if [ "$at_edge" = "1" ]; then
  # No column on that side yet → make the source a full-height column there.
  # Any other pane works as the split target; -f makes it span the full height
  # regardless of which pane we split from.
  target="$(tmux list-panes -F '#{pane_id}' | grep -vxF "$src" | head -1 || true)"
  [ -z "$target" ] && exit 0   # only one pane in the window — nothing to move
  side_flag=''
  [ "$newcol_before" = "1" ] && side_flag='-b'   # left column → source on the left
  tmux join-pane -h -f $side_flag -s "$src" -t "$target"
else
  # A column exists on that side → stack the source into it (above/below).
  tmux join-pane -v $above_flag -s "$src" -t "$neighbor"
fi

# Keep focus on the pane we just moved.
tmux select-pane -t "$src" 2>/dev/null || true
