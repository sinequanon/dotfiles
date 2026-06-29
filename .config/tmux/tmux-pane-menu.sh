#!/usr/bin/env bash
# Native tmux pane switcher + actions (no external dependencies).
#
# Pops up a tmux `display-menu` listing every pane in the CURRENT window:
#
#     * 1: my label        [nvim] dotfiles
#       2: claude review …  [claude] cmp-breakout
#       3: shell            [zsh] ~
#     ───────────────────
#     ✗ Kill a pane…   x
#     ✎ Label a pane…  r
#
# Selecting a pane (mouse click, arrow keys + Enter, or the number shortcut)
# focuses it via `select-pane`. The two footer items open sub-menus to kill a
# pane (with confirmation) or relabel one (reusing set-pane-label.sh, so the
# label shows up in your pane border / tabs immediately).
#
# Reuses the same @pane_label data rendered in the pane border / window tabs,
# falling back to the live command when a pane has no label. Coexists with
# prefix+z zoom: it only ever calls select-pane / kill-pane on demand.
#
# Panes belonging to the persistent sidebar (tmux-pane-sidebar.sh) are excluded
# via `list-panes -f` so they don't clutter the switcher.
#
# Invoked from .tmux.conf as:
#     bind Tab run-shell "$HOME/.config/tmux/tmux-pane-menu.sh '#{window_id}' '#{client_name}'"
#
# run-shell expands the #{window_id} / #{client_name} formats, so the menu is
# always built and displayed against the window/client that pressed the key —
# this matters because run-shell scripts have no ambient "current pane" target.
# The footer sub-menus re-invoke this script (passing the same window/client) in
# a different mode.
#
# Args:
#   $1  target window id   (e.g. @5)            — required for correct scoping
#   $2  target client name (e.g. /dev/pts/3)    — optional, makes display reliable
#   $3  mode: jump (default) | kill | label
#
# Env:
#   PANE_MENU_FORMAT=1   print the would-be display-menu argv (for tests) and
#                        exit without invoking tmux.

set -euo pipefail

win="${1-}"
client="${2-}"
mode="${3:-jump}"

# Resolve sibling scripts by this script's own (symlinked) directory.
self_dir="$(cd "$(dirname "$0")" && pwd -P)"
self="$self_dir/$(basename "$0")"
label_helper="$self_dir/set-pane-label.sh"

TAB=$'\t'
# Field separator is a literal TAB; @pane_label is read LAST so a label that
# somehow contains a tab still leaves the fixed fields intact.
fmt="#{pane_id}${TAB}#{pane_index}${TAB}#{pane_active}${TAB}#{pane_current_command}${TAB}#{b:pane_current_path}${TAB}#{@pane_label}"
# Skip persistent-sidebar panes (see tmux-pane-sidebar.sh).
filter='#{!=:#{@pane_overview_role},sidebar}'

# Build the display-menu argv: triples of (name, key, command), plus an empty
# "" element which display-menu renders as a separator line.
args=()
n=0
while IFS=$'\t' read -r pid idx active cmd cpath label; do
  [ -z "$pid" ] && continue
  n=$((n + 1))

  # Prefer the manual/auto @pane_label; fall back to the live command.
  disp="${label:-$cmd}"

  # In a display-menu the NAME (and confirm-before's -p prompt) is itself a tmux
  # format string, so a literal '#' in user data would be interpreted. Escape
  # '#' as '##'.
  disp=${disp//\#/\#\#}
  ecmd=${cmd//\#/\#\#}
  epath=${cpath//\#/\#\#}

  if [ "$active" = "1" ]; then
    mark='#[fg=colour39]*#[default]'
  else
    mark=' '
  fi

  # Quick-select shortcut: 1-9 then 0 for the tenth pane; none beyond that.
  # An empty key means "no mnemonic" (do NOT use '-', which would make '-' the
  # literal shortcut for every pane past the tenth).
  key=''
  if [ "$n" -le 9 ]; then
    key="$n"
  elif [ "$n" -eq 10 ]; then
    key="0"
  fi

  name="${mark} ${idx}: ${disp} #[fg=colour245][${ecmd}] ${epath}#[default]"

  case "$mode" in
    kill)
      # Confirm before killing. Prompt is a format string, so use escaped text.
      entry="confirm-before -p \"kill pane ${idx} (${ecmd})? (y/n)\" \"kill-pane -t ${pid}\""
      ;;
    label)
      # Focus the pane, then prompt for its label (reusing the same flow as the
      # Prefix+P binding). %% is command-prompt's placeholder for the input.
      entry="select-pane -t ${pid} ; command-prompt -I \"#{@pane_label}\" -p \"pane label (empty clears)\" \"run-shell -b '${label_helper} \\\"%%\\\"'\""
      ;;
    *)
      # jump: scope is the current window, so a bare select-pane suffices.
      entry="select-pane -t ${pid}"
      ;;
  esac

  args+=("$name" "$key" "$entry")
done < <(tmux list-panes ${win:+-t "$win"} -f "$filter" -F "$fmt")

if [ "${#args[@]}" -eq 0 ]; then
  tmux display-message "pane-menu: no panes found"
  exit 0
fi

# Footer + title per mode.
case "$mode" in
  kill)
    args+=("")  # separator
    args+=("#[fg=colour245]← back#[default]" "q" "run-shell \"$self '$win' '$client' jump\"")
    title=" #[align=centre,fg=colour203]kill which pane? "
    ;;
  label)
    args+=("")
    args+=("#[fg=colour245]← back#[default]" "q" "run-shell \"$self '$win' '$client' jump\"")
    title=" #[align=centre,fg=colour114]label which pane? "
    ;;
  *)
    args+=("")
    args+=("#[fg=colour203]✗ Kill a pane…#[default]" "x" "run-shell \"$self '$win' '$client' kill\"")
    args+=("#[fg=colour114]✎ Label a pane…#[default]" "r" "run-shell \"$self '$win' '$client' label\"")
    title=" #[align=centre]panes · #{window_name} "
    ;;
esac

if [ "${PANE_MENU_FORMAT-}" = "1" ]; then
  # Test/debug mode: print one argv element per line and stop.
  printf '%s\n' "${args[@]}"
  exit 0
fi

# -c / -t make the menu render on the correct client/window even though this
# script runs detached from any pane. -x C -y C centers it.
tmux display-menu \
  ${client:+-c "$client"} \
  ${win:+-t "$win"} \
  -x C -y C \
  -T "$title" \
  "${args[@]}"
