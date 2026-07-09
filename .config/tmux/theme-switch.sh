#!/usr/bin/env bash
# Unified color-theme switcher for starship + tmux status bar + pane sidebar +
# pane menu. "Change the whole look on the fly, depending on mood."
#
# One theme is a named set of colors applied across four surfaces at once:
#   • starship  — flips the active `palette = '...'` line in starship.toml
#                 (both palettes live in that file; see [palettes.*] there).
#   • tmux bar  — sets @thm_* user options (referenced by the status-left/right/
#                 -format lines in tmux.conf) and bakes the *-style options.
#   • sidebar   — sets @thm_side_* options; the sidebar reads them (SIGUSR1
#                 makes a running sidebar recolor instantly).
#   • pane menu — sets @thm_menu_* options; the menu reads them when it opens.
#
# The chosen theme is saved to ~/.config/tmux/.theme-active and re-applied to the
# tmux side on every tmux start via `run-shell "theme-switch.sh restore"` in
# tmux.conf, so it survives restarts.
#
# Usage:
#   theme-switch.sh <name>        apply a theme (name: gruvbox | badwolf)
#   theme-switch.sh toggle        switch to the "other" theme
#   theme-switch.sh restore       re-apply the saved theme (tmux start hook)
#   theme-switch.sh current       print the active theme name
#   theme-switch.sh list          list available themes
#   theme-switch.sh menu <win> <client>   pop a tmux display-menu picker
#
# Adding a mood: add a case branch in apply_tmux_options, a [palettes.<name>]
# block in starship.toml, and the name to THEMES below.

set -u

self_dir="$(cd "$(dirname "$0")" && pwd -P)"
self="$self_dir/$(basename "$0")"
sidebar="$self_dir/tmux-pane-sidebar.sh"
STATE="${THEME_STATE:-$HOME/.config/tmux/.theme-active}"
DEFAULT_THEME="gruvbox"
THEMES="gruvbox badwolf"

# --- state ------------------------------------------------------------------
read_state() {
  local t=""
  [ -f "$STATE" ] && t="$(cat "$STATE" 2>/dev/null)"
  case " $THEMES " in *" $t "*) printf '%s' "$t" ;; *) printf '%s' "$DEFAULT_THEME" ;; esac
}

save_state() { mkdir -p "$(dirname "$STATE")" 2>/dev/null; printf '%s\n' "$1" > "$STATE"; }

# --- starship ---------------------------------------------------------------
# Flip the active palette line. Reads/writes through the config (a symlink to
# the repo's starship.toml is fine — writing via a temp file keeps the link).
apply_starship() {
  local pal="$1"
  local f="${STARSHIP_CONFIG:-$HOME/.config/starship.toml}"
  [ -e "$f" ] || return 0
  local tmp; tmp="$(mktemp)" || return 0
  if sed "s/^palette = .*/palette = '$pal'/" "$f" > "$tmp" && [ -s "$tmp" ]; then
    cat "$tmp" > "$f"
  fi
  rm -f "$tmp"
}

# --- tmux -------------------------------------------------------------------
# Set the @thm_* user options for a theme. These drive: the status-left/right/
# -format strings (via #{@thm_*}), the sidebar (@thm_side_*), and the menu
# (@thm_menu_*). Values may be hex (#rrggbb), a tmux colourN, or a raw SGR body
# (sidebar). Baking of the *-style options happens in bake_styles().
apply_tmux_options() {
  case "$1" in
    gruvbox)
      # status bar
      tmux set -g @thm_bg        "#282828"
      tmux set -g @thm_fg        "#fbf1c7"
      tmux set -g @thm_accent    "#d65d0e"
      tmux set -g @thm_accent_fg "#282828"
      tmux set -g @thm_pill      "#d79921"
      tmux set -g @thm_pill_fg   "#282828"
      tmux set -g @thm_mid       "#3d3d3d"
      tmux set -g @thm_dim       "#665c54"
      tmux set -g @thm_msg_bg    "#d79921"
      tmux set -g @thm_msg_fg    "#282828"
      tmux set -g @thm_zoom      "#fbf1c7"
      # sidebar (raw SGR bodies)
      tmux set -g @thm_side_agent  "38;2;211;134;155"
      tmux set -g @thm_side_editor "38;2;131;165;152"
      tmux set -g @thm_side_vcs    "38;2;254;128;25"
      tmux set -g @thm_side_remote "38;2;251;73;52"
      tmux set -g @thm_side_repl   "38;2;142;192;124"
      tmux set -g @thm_side_shell  "38;2;146;131;116"
      tmux set -g @thm_side_other  "38;2;69;133;136"
      tmux set -g @thm_side_idx    "1;38;2;250;189;47"
      tmux set -g @thm_side_lbl    "38;2;235;219;178"
      tmux set -g @thm_side_act    "38;2;214;93;14"
      tmux set -g @thm_side_sel    "1;48;2;69;133;136;38;2;251;241;199"
      tmux set -g @thm_side_dot    "38;2;102;92;84"
      tmux set -g @thm_side_dim    "38;2;146;131;116"
      # menu (tmux color tokens)
      tmux set -g @thm_menu_active "#d65d0e"
      tmux set -g @thm_menu_dim    "#928374"
      tmux set -g @thm_menu_kill   "#fb4934"
      tmux set -g @thm_menu_label  "#b8bb26"
      ;;
    badwolf)
      # status bar (original 256-color "Bad Wolf" values)
      tmux set -g @thm_bg        "colour234"
      tmux set -g @thm_fg        "white"
      tmux set -g @thm_accent    "colour39"
      tmux set -g @thm_accent_fg "colour25"
      tmux set -g @thm_pill      "colour252"
      tmux set -g @thm_pill_fg   "colour235"
      tmux set -g @thm_mid       "colour238"
      tmux set -g @thm_dim       "colour245"
      tmux set -g @thm_msg_bg    "colour221"
      tmux set -g @thm_msg_fg    "colour16"
      tmux set -g @thm_zoom      "colour18"
      # sidebar
      tmux set -g @thm_side_agent  "38;5;170"
      tmux set -g @thm_side_editor "38;5;75"
      tmux set -g @thm_side_vcs    "38;5;215"
      tmux set -g @thm_side_remote "38;5;204"
      tmux set -g @thm_side_repl   "38;5;73"
      tmux set -g @thm_side_shell  "38;5;244"
      tmux set -g @thm_side_other  "38;5;109"
      tmux set -g @thm_side_idx    "1;38;5;220"
      tmux set -g @thm_side_lbl    "38;5;252"
      tmux set -g @thm_side_act    "38;5;48"
      tmux set -g @thm_side_sel    "1;48;5;24;38;5;231"
      tmux set -g @thm_side_dot    "38;5;240"
      tmux set -g @thm_side_dim    "38;5;245"
      # menu
      tmux set -g @thm_menu_active "colour39"
      tmux set -g @thm_menu_dim    "colour245"
      tmux set -g @thm_menu_kill   "colour203"
      tmux set -g @thm_menu_label  "colour114"
      ;;
    *) return 1 ;;
  esac
}

# Bake the *-style options from the @thm_* values. `-F` expands the format at
# set time, so this is robust across tmux versions (no reliance on draw-time
# expansion of style options).
bake_styles() {
  tmux set -gF status-style             "bg=#{@thm_bg},fg=#{@thm_fg}"
  tmux set -gF pane-border-style        "bg=#{@thm_dim}"
  tmux set -gF pane-active-border-style "bg=#{@thm_accent}"
  tmux set -gF message-style            "bg=#{@thm_msg_bg},fg=#{@thm_msg_fg},bold"
}

tmux_running() { tmux info >/dev/null 2>&1; }

apply_tmux() {
  tmux_running || return 0
  apply_tmux_options "$1" || return 1
  bake_styles
  # Recolor any running sidebars (SIGUSR1 -> load_theme + repaint) and force an
  # immediate status-line redraw.
  [ -x "$sidebar" ] && "$sidebar" signal >/dev/null 2>&1 || true
  tmux refresh-client -S >/dev/null 2>&1 || true
}

# --- top-level actions ------------------------------------------------------
apply() {
  local theme="$1"
  case " $THEMES " in *" $theme "*) ;; *) echo "theme: unknown theme '$theme' (have: $THEMES)" >&2; return 2 ;; esac
  case "$theme" in
    gruvbox) apply_starship "gruvbox_dark" ;;
    badwolf) apply_starship "badwolf" ;;
  esac
  apply_tmux "$theme"
  save_state "$theme"
}

show_menu() {
  tmux_running || return 0
  local win="${1-}" client="${2-}" cur; cur="$(read_state)"
  local args=() key mark t
  for t in $THEMES; do
    if [ "$t" = "$cur" ]; then mark="#[fg=#{@thm_accent}]● #[default]"; else mark="  "; fi
    case "$t" in gruvbox) key=g ;; badwolf) key=b ;; *) key="" ;; esac
    args+=("$mark$t" "$key" "run-shell \"$self $t\"")
  done
  tmux display-menu ${client:+-c "$client"} ${win:+-t "$win"} -x C -y C -T " theme " "${args[@]}"
}

cmd="${1:-current}"
case "$cmd" in
  gruvbox|badwolf) apply "$cmd"; echo "theme: $cmd" ;;
  toggle)
    cur="$(read_state)"
    if [ "$cur" = "gruvbox" ]; then apply badwolf; echo "theme: badwolf"; else apply gruvbox; echo "theme: gruvbox"; fi ;;
  restore) apply "$(read_state)" >/dev/null 2>&1 || true ;;
  current) read_state; echo ;;
  list)    for t in $THEMES; do echo "$t"; done ;;
  menu)    show_menu "${2-}" "${3-}" ;;
  -h|--help|help)
    sed -n '2,30p' "$self" | sed 's/^# \{0,1\}//' ;;
  *) echo "usage: $(basename "$0") {gruvbox|badwolf|toggle|restore|current|list|menu}" >&2; exit 2 ;;
esac
