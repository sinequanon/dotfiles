#!/usr/bin/env bash
# Interactive, event-driven pinned pane sidebar for the CURRENT tmux window.
#
# A narrow, full-height pane pinned to the LEFT edge that lists this window's
# panes and lets you navigate between them with the keyboard:
#
#   ▌ panes                    (expanded)        ▌   (collapsed / "minimized")
#   ─────────────                                ─
#   ▸ 1 my label                                 1
#       nvim · dotfiles                          2
#   > 2 claude review <          <- selected     3
#       claude · cmp-breakout
#
# Two visible states so it's always obvious the sidebar is on:
#   • expanded  – full list with labels + command/path sublines
#   • collapsed – a thin strip showing just pane indices (the "minimized" look)
#
# Refresh is EVENT-DRIVEN, not polled: the render loop blocks on a key read that
# is interrupted by SIGUSR1 (sent by tmux hooks on focus/split/kill changes) and
# SIGWINCH (on resize). When idle and unfocused it consumes no CPU. The hooks
# remove themselves once the last sidebar is closed.
#
# Keys (when the sidebar pane is focused — e.g. Alt+h into it, or click it):
#   j / ↓   move selection down        Enter   jump to the selected pane
#   k / ↑   move selection up          c / Spc collapse ⇄ expand
#   g / G   first / last               q       close the sidebar
#
# Relationship to prefix+z zoom: the sidebar is just a tmux pane, so zooming a
# work pane with prefix+z hides everything else including the sidebar (focus
# mode); unzoom brings it back. The sidebar never remaps or interferes with z.
#
# .tmux.conf bindings:
#   bind e run-shell "$HOME/.config/tmux/tmux-pane-sidebar.sh toggle '#{window_id}'"
#   bind E run-shell "$HOME/.config/tmux/tmux-pane-sidebar.sh close  '#{window_id}'"
#
# Stage mode (IDE tabs): `stage` collapses the sidebar to mini, shows ONE content
# pane maximized next to it, and parks the rest in a hidden holding window.
# Selecting a pane in the nav (Enter or mouse click) swaps it onto the stage;
# `stage` again restores all panes with the sidebar expanded: the previously
# staged pane full-height on the left, the others stacked vertically on the right.
#
# Subcommands:
#   toggle <win>          open (focused) if absent, else collapse ⇄ expand
#   close  <win>          remove the sidebar from <win>
#   stage  <win>          toggle stage mode (maximize one pane + mini nav)
#   stage-to <win> <pane> put <pane> on the stage (used by Enter / mouse click)
#   stage-click <win> <y> [<top>]  map a mini-nav click row to a pane and stage it
#   run                   (internal) the render/input loop in the sidebar pane
#   hook                  (internal) fired by tmux hooks: refresh / self-clean
#   signal                (internal) SIGUSR1 every sidebar render loop
#   reload                (internal) restart open sidebars to load script edits
#
# Env overrides:
#   PANE_SIDEBAR_WIDTH   expanded width in columns (default 26)
#   PANE_SIDEBAR_THIN    collapsed width in columns (default 4)

set -uo pipefail

TAB=$'\t'
ESC=$'\033'
NL=$'\n'

ROLE_OPT="@pane_overview_role"
ROLE_VAL="sidebar"
PID_OPT="@pane_overview_pid"
FILTER="#{!=:#{@pane_overview_role},sidebar}"

# Stage mode (IDE-tab "monocle") state, stored as WINDOW options on the staged
# window: one content pane is shown at a time next to a mini sidebar; the others
# are parked in a holding window.
STAGE_ACTIVE_OPT="@stage_active"   # "1" while the window is in stage mode
STAGE_HOLD_OPT="@stage_hold"       # window id of the holding window
STAGE_CUR_OPT="@stage_current"     # pane id currently on the stage

# Shared list-panes format: id, index, active, command, short path, label.
GFMT="#{pane_id}${TAB}#{pane_index}${TAB}#{pane_active}${TAB}#{pane_current_command}${TAB}#{b:pane_current_path}${TAB}#{@pane_label}"

FULL_WIDTH="${PANE_SIDEBAR_WIDTH:-26}"
THIN_WIDTH="${PANE_SIDEBAR_THIN:-4}"
THRESHOLD=8   # render thin when pane width < THRESHOLD
# Refresh is event-driven (tmux hooks -> SIGUSR1). This is only a safety net: if
# a burst of signals is coalesced/missed (e.g. during stage entry), the loop
# still reconciles within this many seconds. Change-detection makes the wakeup a
# no-op when nothing changed, so it neither flickers nor busy-polls.
REFRESH_SAFETY="${PANE_SIDEBAR_REFRESH:-1}"

HOOK_IDX=991
HOOK_EVENTS=(after-select-pane after-split-window after-kill-pane pane-exited)

self_dir="$(cd "$(dirname "$0")" && pwd -P)"
self="$self_dir/$(basename "$0")"

# ---------------------------------------------------------------------------
# tmux helpers
# ---------------------------------------------------------------------------

find_sidebar() { # echo the sidebar pane id in $win (if any)
  tmux list-panes ${win:+-t "$win"} -F "#{pane_id}${TAB}#{${ROLE_OPT}}" 2>/dev/null \
    | awk -F"$TAB" -v r="$ROLE_VAL" '$2 == r { print $1; exit }'
}

sidebar_count_all() { # number of sidebar panes across all windows/sessions
  tmux list-panes -a -f "#{==:#{${ROLE_OPT}},${ROLE_VAL}}" -F x 2>/dev/null | grep -c x || true
}

install_hooks() {
  local e
  for e in "${HOOK_EVENTS[@]}"; do
    tmux set-hook -g "${e}[${HOOK_IDX}]" "run-shell -b '${self} hook'" 2>/dev/null || true
  done
}

remove_hooks() {
  local e
  for e in "${HOOK_EVENTS[@]}"; do
    tmux set-hook -gu "${e}[${HOOK_IDX}]" 2>/dev/null || true
  done
}

signal_all() { # SIGUSR1 every sidebar render loop so it repaints immediately
  local p
  while read -r p; do
    [ -n "$p" ] && kill -USR1 "$p" 2>/dev/null || true
  done < <(tmux list-panes -a -F "#{${PID_OPT}}" 2>/dev/null)
}

# ---------------------------------------------------------------------------
# commands
# ---------------------------------------------------------------------------

create_expanded() {
  local first newid
  first="$(tmux list-panes ${win:+-t "$win"} -F '#{pane_id}' | head -1)"
  [ -z "$first" ] && return 0
  newid="$(tmux split-window -hbf -l "$FULL_WIDTH" -t "$first" -d -P -F '#{pane_id}' "$self" run)"
  tmux set-option -p -t "$newid" "$ROLE_OPT" "$ROLE_VAL"
  tmux set-option -p -t "$newid" remain-on-exit off 2>/dev/null || true
  install_hooks
}

cmd_toggle() {
  local sb w newsb
  sb="$(find_sidebar || true)"
  if [ -z "$sb" ]; then
    create_expanded
    # Opening it implies you want to act on it: move focus into the sidebar so
    # j/k/Enter work immediately. (reload/stage create it without focusing.)
    newsb="$(find_sidebar || true)"
    [ -n "$newsb" ] && tmux select-pane -t "$newsb" 2>/dev/null || true
    return 0
  fi
  w="$(tmux display-message -p -t "$sb" '#{pane_width}' 2>/dev/null || echo "$FULL_WIDTH")"
  if [ "${w:-0}" -ge "$THRESHOLD" ]; then
    tmux resize-pane -t "$sb" -x "$THIN_WIDTH"   # collapse to thin strip
  else
    tmux resize-pane -t "$sb" -x "$FULL_WIDTH"   # expand
  fi
  signal_all   # SIGWINCH usually covers this, but nudge to be safe
}

cmd_close() {
  local sb
  sb="$(find_sidebar || true)"
  [ -n "$sb" ] && tmux kill-pane -t "$sb"
  [ "$(sidebar_count_all)" = "0" ] && remove_hooks || true
}

cmd_reload() {
  # Restart every open sidebar so edits to THIS script take effect. The render
  # loop is a long-lived process, so re-sourcing tmux.conf alone won't refresh
  # it (the Tab menu re-reads on each use and needs no restart). Recreating
  # the pane is the simple, reliable way to pick up new code; a collapsed
  # sidebar comes back expanded.
  local wid sbid
  while read -r wid; do
    [ -z "$wid" ] && continue
    win="$wid"
    sbid="$(find_sidebar || true)"
    if [ -n "$sbid" ]; then
      tmux kill-pane -t "$sbid"
      create_expanded
    fi
  done < <(tmux list-panes -a -f "#{==:#{${ROLE_OPT}},${ROLE_VAL}}" -F '#{window_id}' 2>/dev/null)
}

cmd_hook() {
  # Fired by tmux hooks. If no sidebars remain, uninstall ourselves; otherwise
  # refresh every sidebar.
  if [ "$(sidebar_count_all)" = "0" ]; then
    remove_hooks
    return 0
  fi
  signal_all
}

# ---------------------------------------------------------------------------
# stage mode (IDE-tab "monocle"): one content pane visible at a time next to a
# mini sidebar; other content panes parked in a holding window.
# ---------------------------------------------------------------------------

stage_content_panes() { # echo content pane ids (role != sidebar) in $1, in order
  tmux list-panes -t "$1" -f "$FILTER" -F '#{pane_id}' 2>/dev/null
}

# stage_list_all <win>: pane ids in the exact order the sidebar lists them in
# stage mode — the staged pane (in <win>) followed by the held panes.
stage_list_all() {
  local w="$1" hold
  stage_content_panes "$w"
  hold="$(tmux show-options -wqv -t "$w" "$STAGE_HOLD_OPT" 2>/dev/null || true)"
  [ -n "$hold" ] && tmux list-panes -t "$hold" -F '#{pane_id}' 2>/dev/null
}

stage_enter() {
  local w="$1" sb staged p hwid
  win="$w"
  sb="$(find_sidebar || true)"
  if [ -z "$sb" ]; then
    create_expanded
    sb="$(find_sidebar || true)"
  fi
  [ -z "$sb" ] && return 0

  # Stage the active pane, unless that is the sidebar (then the first content pane).
  staged="$(tmux display-message -p -t "$w" '#{pane_id}' 2>/dev/null)"
  [ "$staged" = "$sb" ] && staged="$(stage_content_panes "$w" | head -1)"
  [ -z "$staged" ] && return 0

  # Move every OTHER content pane into a holding window.
  hwid=""
  while read -r p; do
    [ -z "$p" ] && continue
    [ "$p" = "$staged" ] && continue
    if [ -z "$hwid" ]; then
      hwid="$(tmux break-pane -dP -F '#{window_id}' -s "$p" -n '__stage' 2>/dev/null)"
    else
      tmux join-pane -d -s "$p" -t "$hwid" 2>/dev/null || true
    fi
  done < <(stage_content_panes "$w")

  tmux set-option -w -t "$w" "$STAGE_ACTIVE_OPT" 1
  [ -n "$hwid" ] && tmux set-option -w -t "$w" "$STAGE_HOLD_OPT" "$hwid"
  tmux set-option -w -t "$w" "$STAGE_CUR_OPT" "$staged"

  tmux resize-pane -t "$sb" -x "$THIN_WIDTH" 2>/dev/null || true  # mini nav
  tmux select-pane -t "$staged" 2>/dev/null || true              # work in the staged pane
  signal_all
}

stage_restore() {
  local w="$1" hwid staged sb p
  win="$w"
  hwid="$(tmux show-options -wqv -t "$w" "$STAGE_HOLD_OPT" 2>/dev/null || true)"
  staged="$(tmux show-options -wqv -t "$w" "$STAGE_CUR_OPT" 2>/dev/null || true)"

  # Bring all held panes back into the window (the holding window auto-closes).
  if [ -n "$hwid" ]; then
    while read -r p; do
      [ -z "$p" ] && continue
      tmux join-pane -d -s "$p" -t "$w" 2>/dev/null || true
    done < <(tmux list-panes -t "$hwid" -F '#{pane_id}' 2>/dev/null)
  fi

  tmux set-option -wu -t "$w" "$STAGE_ACTIVE_OPT" 2>/dev/null || true
  tmux set-option -wu -t "$w" "$STAGE_HOLD_OPT" 2>/dev/null || true
  tmux set-option -wu -t "$w" "$STAGE_CUR_OPT" 2>/dev/null || true

  # Restore layout: the previously-staged pane becomes the full-height "main"
  # pane on the left; the other panes stack vertically (evenly) in the remaining
  # space on the right (tmux main-vertical). Drop the sidebar first, lay out the
  # content, make sure the staged pane is the main one, then recreate the sidebar
  # on the far left (it splits the main pane, so the stack is untouched).
  sb="$(find_sidebar || true)"
  [ -n "$sb" ] && tmux kill-pane -t "$sb" 2>/dev/null || true
  tmux set-window-option -t "$w" main-pane-width 50% 2>/dev/null || true
  tmux select-layout -t "$w" main-vertical 2>/dev/null || true
  if [ -n "$staged" ]; then
    local main0
    main0="$(tmux list-panes -t "$w" -F '#{pane_id}' | head -1)"
    [ -n "$main0" ] && [ "$main0" != "$staged" ] && tmux swap-pane -s "$staged" -t "$main0" 2>/dev/null || true
  fi
  create_expanded
  [ -n "$staged" ] && tmux select-pane -t "$staged" 2>/dev/null || true
  signal_all
}

cmd_stage() { # toggle stage mode for <win>
  local w="$1" active
  active="$(tmux show-options -wqv -t "$w" "$STAGE_ACTIVE_OPT" 2>/dev/null || true)"
  if [ "$active" = "1" ]; then stage_restore "$w"; else stage_enter "$w"; fi
}

cmd_stage_to() { # put <target> on the stage, park the current staged pane
  local w="$1" target="$2" cur hwid sb
  win="$w"
  cur="$(tmux show-options -wqv -t "$w" "$STAGE_CUR_OPT" 2>/dev/null || true)"
  [ "$target" = "$cur" ] && { tmux select-pane -t "$target" 2>/dev/null || true; return 0; }
  hwid="$(tmux show-options -wqv -t "$w" "$STAGE_HOLD_OPT" 2>/dev/null || true)"
  [ -z "$hwid" ] && return 0
  sb="$(find_sidebar || true)"
  # Park the current pane first (so the holding window never empties mid-swap),
  # then bring the target onto the stage to the right of the mini sidebar.
  [ -n "$cur" ] && tmux join-pane -d -s "$cur" -t "$hwid" 2>/dev/null || true
  if [ -n "$sb" ]; then
    tmux join-pane -d -h -s "$target" -t "$sb" 2>/dev/null || true
    tmux resize-pane -t "$sb" -x "$THIN_WIDTH" 2>/dev/null || true
  else
    tmux join-pane -d -s "$target" -t "$w" 2>/dev/null || true
  fi
  tmux set-option -w -t "$w" "$STAGE_CUR_OPT" "$target"
  tmux select-pane -t "$target" 2>/dev/null || true
  signal_all
}

cmd_stage_click() { # map a mini-sidebar click row to a pane and stage it
  local w="$1" y="${2:-0}" top="${3:-0}" row target
  row=$((y - top)); [ "$row" -lt 0 ] && return 0
  target="$(stage_list_all "$w" | sed -n "$((row + 1))p")"
  [ -n "$target" ] && cmd_stage_to "$w" "$target"
}

# ---------------------------------------------------------------------------
# render loop (runs as the sidebar pane's command)
# ---------------------------------------------------------------------------

# Globals filled by gather():
P_ID=(); P_IDX=(); P_ACT=(); P_CMD=(); P_PATH=(); P_LABEL=(); N=0; AIDX=-1; IN_STAGE=0

gather() {
  local mywin="$1" id idx act cmd cpath label stage hold current
  P_ID=(); P_IDX=(); P_ACT=(); P_CMD=(); P_PATH=(); P_LABEL=(); N=0; AIDX=-1
  stage="$(tmux show-options -wqv -t "$mywin" "$STAGE_ACTIVE_OPT" 2>/dev/null || true)"

  if [ "$stage" = "1" ]; then
    # Stage mode: list the staged pane (in this window) + the held panes (in the
    # holding window), so the nav can switch between all of them. The "active"
    # marker is the staged pane (@stage_current), and the shown index is the
    # 1-based nav position (held panes have window-relative indices that would
    # otherwise collide/jump around).
    IN_STAGE=1
    hold="$(tmux show-options -wqv -t "$mywin" "$STAGE_HOLD_OPT" 2>/dev/null || true)"
    current="$(tmux show-options -wqv -t "$mywin" "$STAGE_CUR_OPT" 2>/dev/null || true)"
    while IFS="$TAB" read -r id idx act cmd cpath label; do
      [ -z "$id" ] && continue
      P_ID+=("$id"); P_IDX+=("$((N + 1))")
      if [ "$id" = "$current" ]; then P_ACT+=("1"); AIDX="$N"; else P_ACT+=("0"); fi
      P_CMD+=("$cmd"); P_PATH+=("$cpath"); P_LABEL+=("$label")
      N=$((N + 1))
    done < <(
      tmux list-panes -t "$mywin" -f "$FILTER" -F "$GFMT" 2>/dev/null
      [ -n "$hold" ] && tmux list-panes -t "$hold" -F "$GFMT" 2>/dev/null
    )
  else
    IN_STAGE=0
    while IFS="$TAB" read -r id idx act cmd cpath label; do
      [ -z "$id" ] && continue
      P_ID+=("$id"); P_IDX+=("$idx"); P_ACT+=("$act")
      P_CMD+=("$cmd"); P_PATH+=("$cpath"); P_LABEL+=("$label")
      [ "$act" = "1" ] && AIDX="$N"
      N=$((N + 1))
    done < <(tmux list-panes -t "$mywin" -f "$FILTER" -F "$GFMT" 2>/dev/null)
  fi
}

trunc() { # trunc <string> <max>
  local s="$1" m="$2"
  if [ "${#s}" -gt "$m" ]; then printf '%s' "${s:0:m-1}…"; else printf '%s' "$s"; fi
}

# cmd_color <command> -> echoes a 256-color SGR for that command category, so
# the command line is scannable at a glance (agents pop, shells recede).
cmd_color() {
  case "$1" in
    pi|codex|claude|aider|llm|ollama)                  printf '%s[38;5;170m' "$ESC" ;; # agents: magenta
    vim|nvim|vi|view|nano|hx|helix|emacs|micro|code|kak) printf '%s[38;5;75m'  "$ESC" ;; # editors: blue
    git|lazygit|gitui|tig|gh)                          printf '%s[38;5;215m' "$ESC" ;; # vcs: amber
    ssh|mosh|et|kubectl|docker)                        printf '%s[38;5;204m' "$ESC" ;; # remote/infra: pink
    python|python3|node|ruby|irb|psql|R|julia)         printf '%s[38;5;73m'  "$ESC" ;; # REPLs: teal
    zsh|bash|sh|fish|dash|tmux)                        printf '%s[38;5;244m' "$ESC" ;; # shells: dim
    *)                                                 printf '%s[38;5;109m' "$ESC" ;; # other: slate
  esac
}

# render <width> <sel> -> prints the full frame (real ESC + newlines)
render() {
  local width="$1" sel="$2"
  local rst="${ESC}[0m"
  local c_idx="${ESC}[1;38;5;220m"          # index: bold gold (scan anchor)
  local c_lbl="${ESC}[38;5;252m"            # label: bright
  local c_act="${ESC}[38;5;48m"             # active chevron: green
  local c_sel="${ESC}[1;48;5;24;38;5;231m"  # selected row: blue bar, bright bold
  local c_dot="${ESC}[38;5;240m"            # the · separator: faint
  local c_dim="${ESC}[38;5;245m"            # path: dim
  local out="" i

  if [ "$width" -lt "$THRESHOLD" ]; then
    # ---- thin strip: just the indices (no header) ----------------------
    for ((i = 0; i < N; i++)); do
      local idx="${P_IDX[$i]}"
      if [ "$i" = "$sel" ]; then
        out+="${c_sel} ${idx} ${rst}${NL}"
      elif [ "$i" = "$AIDX" ]; then
        out+="${c_act}${idx}${rst}${NL}"
      else
        out+="${c_idx}${idx}${rst}${NL}"
      fi
    done
    printf '%s' "$out"
    return 0
  fi

  # ---- expanded: per-pane title line + command/path subline (no header) --
  if [ "$N" = "0" ]; then
    out+="${c_dim} (no panes)${rst}${NL}"
    printf '%s' "$out"
    return 0
  fi
  for ((i = 0; i < N; i++)); do
    local idx="${P_IDX[$i]}" disp cmd cpath mk lblw labelt plain pad ccmd cbud cmdt pbud patht
    disp="${P_LABEL[$i]:-${P_CMD[$i]}}"
    cmd="${P_CMD[$i]}"; cpath="${P_PATH[$i]}"
    if [ "$i" = "$AIDX" ]; then mk="▸ "; else mk="  "; fi

    # title row: chevron + gold index + bright label (or a full blue bar if
    # this is the selected/active row).
    lblw=$((width - 3 - ${#idx})); [ "$lblw" -lt 1 ] && lblw=1
    labelt="$(trunc "$disp" "$lblw")"
    if [ "$i" = "$sel" ]; then
      plain="${mk}${idx} ${labelt}"
      pad=$((width - ${#plain})); [ "$pad" -lt 0 ] && pad=0
      out+="${c_sel}${plain}$(printf '%*s' "$pad" '')${rst}${NL}"
    elif [ "$i" = "$AIDX" ]; then
      out+="${c_act}▸ ${rst}${c_idx}${idx}${rst} ${c_lbl}${labelt}${rst}${NL}"
    else
      out+="  ${c_idx}${idx}${rst} ${c_lbl}${labelt}${rst}${NL}"
    fi

    # subline: command (category color) · path (dim)
    ccmd="$(cmd_color "$cmd")"
    cbud=$((width - 4)); [ "$cbud" -lt 4 ] && cbud=4
    cmdt="$(trunc "$cmd" "$cbud")"
    pbud=$((cbud - ${#cmdt} - 3)); [ "$pbud" -lt 1 ] && pbud=1
    patht="$(trunc "$cpath" "$pbud")"
    out+="    ${ccmd}${cmdt}${rst}${c_dot} · ${rst}${c_dim}${patht}${rst}${NL}"
  done
  printf '%s' "$out"
}

# repaint: re-gather the pane list and paint if it changed. Reads/updates
# run_loop's locals (myid, mywin, sel, last, width) via dynamic scope and is
# only ever called from run_loop or its USR1/WINCH trap.
repaint() {
  width="$(tmux display-message -p -t "$myid" '#{pane_width}' 2>/dev/null || echo "$FULL_WIDTH")"
  [ -z "$width" ] && width="$FULL_WIDTH"
  gather "$mywin"
  # Selection (the highlight bar) placement:
  #  - Normal mode: it tracks focus — when a work pane is active (AIDX >= 0, you
  #    are not in the sidebar) the bar snaps to it so it matches the ▸ chevron;
  #    only when the sidebar is focused do you move it freely with j/k.
  #  - Stage mode: the ▸ marks the *staged* pane, but the selection cursor moves
  #    freely with j/k (so you can pick which pane to stage); start it on staged.
  if [ "$N" -gt 0 ]; then
    if [ "$IN_STAGE" = "1" ]; then
      if [ "$sel" -lt 0 ] || [ "$sel" -ge "$N" ]; then
        if [ "$AIDX" -ge 0 ]; then sel="$AIDX"; else sel=0; fi
      fi
    elif [ "$AIDX" -ge 0 ]; then
      sel="$AIDX"
    elif [ "$sel" -lt 0 ] || [ "$sel" -ge "$N" ]; then
      sel=0
    fi
  else
    sel=-1
  fi
  local out; out="$(render "$width" "$sel")"
  if [ "$out" != "$last" ]; then
    printf '%s[H%s[2J%s' "$ESC" "$ESC" "$out"
    last="$out"
  fi
}

run_loop() {
  local myid mywin width sel=-1 last="" key rest stty_orig rc running=1

  # Identify OUR OWN pane via $TMUX_PANE (the sidebar is created with -d, so it
  # is never the active pane — display-message without -t would target the wrong
  # pane and report the wrong width).
  myid="${TMUX_PANE:-}"
  [ -z "$myid" ] && myid="$(tmux display-message -p '#{pane_id}')"
  mywin="$(tmux display-message -p -t "$myid" '#{window_id}')"
  tmux set-option -p -t "$myid" "$PID_OPT" "$$" 2>/dev/null || true

  # Instant single-key input (non-canonical, no echo); restore + cleanup on exit.
  stty_orig="$(stty -g 2>/dev/null || true)"
  stty -echo -icanon min 1 time 0 2>/dev/null || true
  printf '%s[?25l' "$ESC"   # hide cursor
  cleanup() {
    [ -n "$stty_orig" ] && stty "$stty_orig" 2>/dev/null || true
    printf '%s[?25h' "$ESC"
    tmux set-option -pu -t "$myid" "$PID_OPT" 2>/dev/null || true
  }
  trap cleanup EXIT TERM
  # Event-driven refresh: tmux hooks send SIGUSR1 and resizes send SIGWINCH. In
  # bash a trapped signal runs the handler but does NOT interrupt a blocking
  # `read`, so we repaint FROM the handler (it runs while read is parked). On
  # shells where a signal does interrupt read, the rc>128 branch below repaints.
  trap repaint USR1 WINCH

  repaint
  while [ "$running" = "1" ]; do
    IFS= read -rsN1 -t "$REFRESH_SAFETY" key; rc=$?
    if [ "$rc" -gt 128 ]; then
      repaint; continue          # timeout (safety net) or signal-interrupted read -> refresh
    elif [ "$rc" -ne 0 ]; then
      break                       # EOF: the pane is closing
    fi
    if [ "$key" = "$ESC" ]; then
      # Possible arrow sequence: grab the next 2 bytes quickly.
      IFS= read -rsN2 -t 0.01 rest 2>/dev/null || rest=""
      case "$rest" in
        '[A') key=UP ;; '[B') key=DOWN ;; '[C') key=RIGHT ;; '[D') key=LEFT ;;
        *) key=ESCAPE ;;
      esac
    fi

    case "$key" in
      j|DOWN)  [ "$N" -gt 0 ] && [ "$sel" -lt $((N - 1)) ] && sel=$((sel + 1)) ;;
      k|UP)    [ "$N" -gt 0 ] && [ "$sel" -gt 0 ] && sel=$((sel - 1)) ;;
      g)       [ "$N" -gt 0 ] && sel=0 ;;
      G)       [ "$N" -gt 0 ] && sel=$((N - 1)) ;;
      "$NL"|$'\r')   # Enter: stage the selected pane (stage mode) or jump to it
        if [ "$N" -gt 0 ]; then
          if [ "$IN_STAGE" = "1" ]; then
            cmd_stage_to "$mywin" "${P_ID[$sel]}"
          else
            tmux select-pane -t "${P_ID[$sel]}" 2>/dev/null || true
          fi
        fi ;;
      c|' ')   # collapse <-> expand (render adapts to the new width via WINCH)
        if [ "$width" -ge "$THRESHOLD" ]; then
          tmux resize-pane -t "$myid" -x "$THIN_WIDTH" 2>/dev/null || true
        else
          tmux resize-pane -t "$myid" -x "$FULL_WIDTH" 2>/dev/null || true
        fi ;;
      q|ESCAPE)
        if [ "$IN_STAGE" = "1" ]; then
          # Don't just close the sidebar (that would strand the held panes);
          # restore stage mode in a separate process (it kills+recreates the
          # sidebar, so this loop ends cleanly on EOF).
          tmux run-shell -b "$self stage '$mywin'" 2>/dev/null || true
        else
          running=0
        fi ;;
    esac
    repaint
  done
}

# ---------------------------------------------------------------------------
# render-once mode for tests: SIDEBAR_RENDER_ONCE=1 SIDEBAR_TEST_WIDTH SEL
# reads panes via (mock) tmux and prints a single frame.
# ---------------------------------------------------------------------------
if [ "${SIDEBAR_RENDER_ONCE:-}" = "1" ]; then
  gather "${SIDEBAR_TEST_WIN:-@0}"
  sel="${SIDEBAR_TEST_SEL:-0}"
  # Mirror repaint()'s selection rule.
  if [ "$N" = "0" ]; then sel=-1
  elif [ "$IN_STAGE" = "1" ]; then
    if [ "$sel" -lt 0 ] || [ "$sel" -ge "$N" ]; then
      if [ "$AIDX" -ge 0 ]; then sel="$AIDX"; else sel=0; fi
    fi
  elif [ "$AIDX" -ge 0 ]; then sel="$AIDX"
  elif [ "$sel" -lt 0 ] || [ "$sel" -ge "$N" ]; then sel=0
  fi
  render "${SIDEBAR_TEST_WIDTH:-26}" "$sel"
  exit 0
fi

cmd="${1:-toggle}"
win="${2-}"

case "$cmd" in
  toggle)     cmd_toggle ;;
  close)      cmd_close ;;
  run)        run_loop ;;
  hook)       cmd_hook ;;
  signal)     signal_all ;;
  reload)     cmd_reload ;;
  stage)      cmd_stage "$win" ;;
  stage-to)   cmd_stage_to "$win" "${3-}" ;;
  stage-click) cmd_stage_click "$win" "${3-}" "${4-}" ;;
  *) printf 'usage: %s {toggle|close|stage <window_id>|stage-to <win> <pane>|run|hook|signal|reload}\n' "$(basename "$0")" >&2; exit 2 ;;
esac
