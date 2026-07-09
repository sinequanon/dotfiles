#!/usr/bin/env bash
# Regression tests for the color-theme switcher (theme-switch.sh) and the
# theme-aware surfaces (starship.toml, tmux.conf, sidebar, menu).
#
# Fully isolated: every switcher call runs with $TMUX pinned to a throwaway
# tmux server (-L), and state/starship go to temp files, so it never touches
# your real tmux session, ~/.config/tmux/.theme-active, or starship config.
# Exits non-zero on any failure.
#
#   bash .config/tmux/theme-switch.test.sh
set -u

DIR="$(cd "$(dirname "$0")" && pwd -P)"
ROOT="$(cd "$DIR/../.." && pwd -P)"
SW="$DIR/theme-switch.sh"
S1="themetest_${$}_a"      # main server: real tmux.conf loaded (status-left defined)
S2="themetest_${$}_b"      # empty server: for the sidebar unset-options fallback
STATE_TMP="$(mktemp)"; : > "$STATE_TMP"
SS_TMP="$(mktemp)"
export THEME_STATE="$STATE_TMP"

pass=0; fail=0
ok(){ pass=$((pass+1)); printf 'ok   %s\n' "$1"; }
no(){ fail=$((fail+1)); printf 'FAIL %s\n' "$1"; }
is(){ if [ "$2" = "$3" ]; then ok "$1"; else no "$1 (got: $2)"; fi; }
has(){ case "$2" in *"$3"*) ok "$1" ;; *) no "$1 (missing: $3)";; esac; }

cleanup(){ tmux -L "$S1" kill-server 2>/dev/null; tmux -L "$S2" kill-server 2>/dev/null; rm -f "$STATE_TMP" "$SS_TMP"; }
trap cleanup EXIT

triple(){ local L="$1"; printf '%s,%s,%s' \
  "$(tmux -L "$L" display-message -p '#{socket_path}')" \
  "$(tmux -L "$L" display-message -p '#{pid}')" \
  "$(tmux -L "$L" display-message -p '#{session_id}')"; }

# 1) static syntax of every theme-touched shell script
for f in theme-switch.sh tmux-pane-sidebar.sh tmux-pane-menu.sh; do
  if bash -n "$DIR/$f" 2>/dev/null; then ok "bash -n $f"; else no "bash -n $f"; fi
done

# 2) pure (no tmux) queries
is "list themes"    "$("$SW" list | tr '\n' ' ')" "gruvbox badwolf "
is "default current" "$("$SW" current)" "gruvbox"

# --- bring up throwaway servers; pin $TMUX so the switcher never hits the real one
tmux -L "$S1" -f "$ROOT/tmux.conf" new-session -d -x 200 -y 50 'sleep 40' 2>/dev/null
tmux -L "$S2" -f /dev/null          new-session -d -x 200 -y 50 'sleep 40' 2>/dev/null
export TMUX="$(triple "$S1")"

# 3) starship palette flip (both directions) on a throwaway copy
cp "$ROOT/starship.toml" "$SS_TMP"
STARSHIP_CONFIG="$SS_TMP" "$SW" badwolf >/dev/null 2>&1
if grep -q "^palette = 'badwolf'"      "$SS_TMP"; then ok "starship->badwolf"; else no "starship->badwolf"; fi
STARSHIP_CONFIG="$SS_TMP" "$SW" gruvbox >/dev/null 2>&1
if grep -q "^palette = 'gruvbox_dark'" "$SS_TMP"; then ok "starship->gruvbox"; else no "starship->gruvbox"; fi

# 4) state persistence + toggle (STARSHIP_CONFIG=/dev/null keeps starship a no-op)
export STARSHIP_CONFIG=/dev/null
"$SW" badwolf >/dev/null 2>&1; is "state=badwolf"   "$(cat "$STATE_TMP")" "badwolf"
"$SW" toggle  >/dev/null 2>&1; is "toggle->gruvbox" "$(cat "$STATE_TMP")" "gruvbox"
"$SW" toggle  >/dev/null 2>&1; is "toggle->badwolf" "$(cat "$STATE_TMP")" "badwolf"

# 5) tmux side: options set + *-style baked to literals + format lines expand
"$SW" gruvbox >/dev/null 2>&1
is  "gruvbox @thm_accent"     "$(tmux -L "$S1" show-options -gv @thm_accent)"                "#d65d0e"
is  "gruvbox status-style"    "$(tmux -L "$S1" show-options -gv status-style)"               "bg=#282828,fg=#fbf1c7"
is  "gruvbox active-border"   "$(tmux -L "$S1" show-options -gv pane-active-border-style)"   "bg=#d65d0e"
is  "gruvbox @thm_side_agent" "$(tmux -L "$S1" show-options -gv @thm_side_agent)"            "38;2;211;134;155"
has "gruvbox status-left expands" "$(tmux -L "$S1" display-message -p '#{E:status-left}')"   "bg=#d79921"

"$SW" badwolf >/dev/null 2>&1
is  "badwolf @thm_accent"    "$(tmux -L "$S1" show-options -gv @thm_accent)"    "colour39"
is  "badwolf status-style"   "$(tmux -L "$S1" show-options -gv status-style)"   "bg=colour234,fg=white"
is  "badwolf message-style"  "$(tmux -L "$S1" show-options -gv message-style)"  "bg=colour221,fg=colour16,bold"
has "badwolf status-left expands" "$(tmux -L "$S1" display-message -p '#{E:status-left}')" "bg=colour252"

# 6) menu reads @thm_menu_* (set to badwolf on S1 by the last apply) + fallback
w1="$(tmux -L "$S1" display-message -p '#{window_id}')"
menu_bw="$(PANE_MENU_FORMAT=1 bash "$DIR/tmux-pane-menu.sh" "$w1" '' jump 2>&1)"
has "menu uses @thm option"  "$menu_bw" "#[fg=colour39]"
# fallback: empty server S2 has no @thm_menu_* -> gruvbox defaults
w2="$(tmux -L "$S2" display-message -p '#{window_id}')"
menu_fb="$(TMUX="$(triple "$S2")" PANE_MENU_FORMAT=1 bash "$DIR/tmux-pane-menu.sh" "$w2" '' jump 2>&1)"
has "menu fallback gruvbox"  "$menu_fb" "#[fg=#d65d0e]"

# 7) sidebar renders gruvbox fallback when @thm_side_* unset (empty server S2)
side_fb="$(TMUX="$(triple "$S2")" SIDEBAR_RENDER_ONCE=1 SIDEBAR_TEST_WIDTH=26 bash "$DIR/tmux-pane-sidebar.sh" 2>/dev/null)"
has "sidebar fallback SGR"    "$side_fb" "38;2;146;131;116"
# and reads the option when set (badwolf) on S1
tmux -L "$S1" set -g @thm_side_dim "38;5;245" >/dev/null 2>&1
side_bw="$(TMUX="$(triple "$S1")" SIDEBAR_RENDER_ONCE=1 SIDEBAR_TEST_WIDTH=26 bash "$DIR/tmux-pane-sidebar.sh" 2>/dev/null)"
has "sidebar reads option"    "$side_bw" "38;5;245"

echo "-----"
echo "passed: $pass  failed: $fail"
[ "$fail" -eq 0 ]
