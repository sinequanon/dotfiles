#!/usr/bin/env bash
#
# sync-tmux-from-work.sh — sync the tmux config + pane-overview helpers from the
# work dotfiles repo into THIS (personal) dotfiles repo, then (re)link the
# helper scripts into their live locations so the change is immediately usable.
#
# The two repos use different filename conventions, so the tmux files need a
# small name remap and the helper scripts need symlinking into place. This
# script encodes all of that once so it never has to be done by hand again.
#
#   SOURCE  work.dotfiles   (default ~/github/work.dotfiles, $WORK_DOTFILES_DIR)
#             .tmux.conf, .config/tmux/*        ($HOME-relative, leading dot)
#   TARGET  this dotfiles repo (this script's git root, or $DOTFILES_DIR)
#             tmux.conf, .config/tmux/*         (top-level dot stripped)
#
# File map (TARGET is mirrored from SOURCE, including upstream deletions):
#   .tmux.conf        ->  tmux.conf
#   .config/tmux/<f>  ->  .config/tmux/<f>
#
# Live links it (re)creates — idempotent, mirrors the work.dotfiles installers
# (installers/zz-tmux-pane-overview-setup.sh + zz-tmux-agent-pane-label-setup.sh):
#   tmux.conf                              -> ~/.tmux.conf                          (0644)
#   .config/tmux/tmux-pane-icon.sh         -> ~/.config/tmux/                       (0644, sourced)
#   .config/tmux/tmux-pane-menu.sh         -> ~/.config/tmux/                       (0755)
#   .config/tmux/tmux-pane-sidebar.sh      -> ~/.config/tmux/                       (0755)
#   .config/tmux/set-pane-label.sh         -> ~/.config/tmux/                       (0755)
#   .config/tmux/tmux-agent-pane-label.zsh -> ~/.oh-my-zsh/custom/                  (0644, if oh-my-zsh)
#   ...and removes a stale ~/.config/tmux/tmux-pane-dashboard.sh if present.
#
# Usage: sync-tmux-from-work.sh [-n|--dry-run] [--pull] [--reload]
#                               [--commit] [--push] [-h|--help]
#   -n, --dry-run  print what would change; modify nothing
#       --pull     `git pull --ff-only` the work repo first (needs network + creds)
#       --reload   reload a running tmux server after syncing
#       --commit   stage tmux.conf + .config/tmux/ and commit them in this repo
#       --push     implies --commit, then `git push`
#   -h, --help     show this help
#
# Default (no flags): sync files + relink + validate + report. No git, no reload.

set -euo pipefail

usage() { sed -n '2,/^set -euo/p' "$0" | sed '$d; s/^#\{0,1\} \{0,1\}//'; }

DRY=0; DO_PULL=0; DO_RELOAD=0; DO_COMMIT=0; DO_PUSH=0
while [ $# -gt 0 ]; do
  case "$1" in
    -n|--dry-run) DRY=1 ;;
    --pull)       DO_PULL=1 ;;
    --reload)     DO_RELOAD=1 ;;
    --commit)     DO_COMMIT=1 ;;
    --push)       DO_COMMIT=1; DO_PUSH=1 ;;
    -h|--help)    usage; exit 0 ;;
    *) printf 'unknown option: %s (try --help)\n' "$1" >&2; exit 2 ;;
  esac
  shift
done

log()  { printf '%s\n' "$*"; }
info() { printf '  %s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die()  { printf 'error: %s\n' "$*" >&2; exit 1; }

# Resolve repos. DOTFILES_DIR defaults to this script's git root; WORK_DOTFILES_DIR
# defaults to ~/github/work.dotfiles. Both are overridable via the environment.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
DOTFILES_DIR="${DOTFILES_DIR:-$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null || dirname "$SCRIPT_DIR")}"
WORK_DIR="${WORK_DOTFILES_DIR:-$HOME/github/work.dotfiles}"

[ -d "$WORK_DIR" ]            || die "work dotfiles repo not found: $WORK_DIR (set WORK_DOTFILES_DIR)"
[ -f "$WORK_DIR/.tmux.conf" ] || die "no .tmux.conf in work repo: $WORK_DIR"
[ -d "$DOTFILES_DIR" ]        || die "dotfiles repo not found: $DOTFILES_DIR (set DOTFILES_DIR)"

CHANGED=0; LINKED=0

# Copy one file (content-compared) honoring --dry-run; reports add/update.
sync_file() { # src dest rel
  local src="$1" dest="$2" rel="$3"
  [ -e "$src" ] || { warn "source missing, skipping: $src"; return 0; }
  cmp -s "$src" "$dest" 2>/dev/null && return 0
  if [ -e "$dest" ]; then info "update  $rel"; else info "add     $rel"; fi
  CHANGED=1
  [ "$DRY" = 1 ] && return 0
  mkdir -p "$(dirname "$dest")"
  cp -f "$src" "$dest"
}

# Mirror a flat directory of files (add/update + delete files gone upstream).
sync_dir() { # srcdir destdir relprefix
  local srcd="$1" destd="$2" relp="$3" f base
  [ "$DRY" = 1 ] || mkdir -p "$destd"
  shopt -s nullglob
  for f in "$srcd"/*; do base="${f##*/}"; sync_file "$f" "$destd/$base" "$relp/$base"; done
  for f in "$destd"/*; do
    base="${f##*/}"
    if [ ! -e "$srcd/$base" ]; then
      info "delete  $relp/$base"; CHANGED=1
      [ "$DRY" = 1 ] || rm -f "$f"
    fi
  done
  shopt -u nullglob
}

# Idempotently point dest at src (symlink), backing up a conflicting real file.
link_file() { # src dest mode
  local src="$1" dest="$2" mode="$3"
  [ -e "$src" ] || { warn "link source missing, skipping: $src"; return 0; }
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    [ "$DRY" = 1 ] || chmod "$mode" "$src" 2>/dev/null || true
    return 0
  fi
  if   [ -L "$dest" ]; then info "relink  $dest -> $src (was $(readlink "$dest"))"
  elif [ -e "$dest" ]; then info "link    $dest -> $src (existing file backed up)"
  else                      info "link    $dest -> $src"
  fi
  LINKED=1
  [ "$DRY" = 1 ] && return 0
  chmod "$mode" "$src" 2>/dev/null || true
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ]; then
    ln -sfn "$src" "$dest"
  elif [ -e "$dest" ]; then
    if cmp -s "$src" "$dest"; then rm -f "$dest"; else mv "$dest" "$dest.bak.$(date +%s)"; fi
    ln -s "$src" "$dest"
  else
    ln -s "$src" "$dest"
  fi
}

WORK_HEAD="$(git -C "$WORK_DIR" rev-parse --short HEAD 2>/dev/null || echo '?')"
LBL=""; [ "$DRY" = 1 ] && LBL=" (dry-run)"
log "tmux sync${LBL}:  $WORK_DIR  ->  $DOTFILES_DIR"
log "work HEAD: $WORK_HEAD"

if [ "$DO_PULL" = 1 ]; then
  log ""; log "==> pull work repo"
  if [ "$DRY" = 1 ]; then info "[dry-run] git -C $WORK_DIR pull --ff-only"
  else git -C "$WORK_DIR" pull --ff-only; WORK_HEAD="$(git -C "$WORK_DIR" rev-parse --short HEAD)"; fi
fi

log ""; log "==> files"
sync_file "$WORK_DIR/.tmux.conf"   "$DOTFILES_DIR/tmux.conf"        "tmux.conf"
sync_dir  "$WORK_DIR/.config/tmux" "$DOTFILES_DIR/.config/tmux"     ".config/tmux"
[ "$CHANGED" = 0 ] && info "(no file changes)"

log ""; log "==> live links"
link_file "$DOTFILES_DIR/tmux.conf"                         "$HOME/.tmux.conf"                       0644
link_file "$DOTFILES_DIR/.config/tmux/tmux-pane-icon.sh"    "$HOME/.config/tmux/tmux-pane-icon.sh"   0644
link_file "$DOTFILES_DIR/.config/tmux/tmux-pane-menu.sh"    "$HOME/.config/tmux/tmux-pane-menu.sh"   0755
link_file "$DOTFILES_DIR/.config/tmux/tmux-pane-sidebar.sh" "$HOME/.config/tmux/tmux-pane-sidebar.sh" 0755
link_file "$DOTFILES_DIR/.config/tmux/set-pane-label.sh"    "$HOME/.config/tmux/set-pane-label.sh"   0755
if [ -d "$HOME/.oh-my-zsh" ]; then
  link_file "$DOTFILES_DIR/.config/tmux/tmux-agent-pane-label.zsh" "$HOME/.oh-my-zsh/custom/tmux-agent-pane-label.zsh" 0644
else
  warn "oh-my-zsh not found; skipping tmux-agent-pane-label.zsh hook"
fi
if [ -L "$HOME/.config/tmux/tmux-pane-dashboard.sh" ]; then
  info "remove stale ~/.config/tmux/tmux-pane-dashboard.sh"
  [ "$DRY" = 1 ] || rm -f "$HOME/.config/tmux/tmux-pane-dashboard.sh"
fi
[ "$LINKED" = 0 ] && info "(all links already current)"

# Validate the result (skipped in dry-run, which hasn't written anything).
if [ "$DRY" = 0 ]; then
  log ""; log "==> validate"
  ok=1
  shopt -s nullglob
  for f in "$DOTFILES_DIR"/.config/tmux/*.sh; do
    bash -n "$f" 2>/dev/null || { warn "shell syntax error: $f"; ok=0; }
  done
  shopt -u nullglob
  if command -v tmux >/dev/null 2>&1; then
    sock="synctmux_$$"; perr="$(mktemp)"
    if tmux -f "$DOTFILES_DIR/tmux.conf" -L "$sock" new-session -d "true" 2>"$perr"; then
      tmux -L "$sock" kill-server 2>/dev/null || true
      info "tmux.conf parses OK"
    else
      warn "tmux.conf parse failed: $(cat "$perr")"; ok=0
    fi
    rm -f "$perr"
  fi
  [ "$ok" = 1 ] || die "validation failed (see warnings above)"
  info "scripts pass bash -n"
fi

if [ "$DO_RELOAD" = 1 ]; then
  log ""; log "==> reload"
  if [ "$DRY" = 1 ]; then info "[dry-run] would reload running tmux"
  elif command -v tmux >/dev/null 2>&1 && tmux info >/dev/null 2>&1; then
    tmux source-file "$HOME/.tmux.conf" && info "reloaded ~/.tmux.conf"
    "$HOME/.config/tmux/tmux-pane-sidebar.sh" reload >/dev/null 2>&1 || true
  else
    warn "no running tmux server to reload"
  fi
fi

if [ "$DO_COMMIT" = 1 ]; then
  log ""; log "==> git"
  if [ "$DRY" = 1 ]; then
    PUSHTXT=""; [ "$DO_PUSH" = 1 ] && PUSHTXT=" && git push"
    info "[dry-run] git add tmux.conf .config/tmux/ && git commit${PUSHTXT}"
  else
    git -C "$DOTFILES_DIR" add tmux.conf .config/tmux/
    if git -C "$DOTFILES_DIR" diff --cached --quiet; then
      info "nothing staged to commit"
    else
      git -C "$DOTFILES_DIR" commit -m "tmux: sync from work.dotfiles ($WORK_HEAD)"
      info "committed"
      [ "$DO_PUSH" = 1 ] && { git -C "$DOTFILES_DIR" push && info "pushed"; }
    fi
  fi
fi

log ""
if [ "$DRY" = 1 ]; then
  log "Dry run only — nothing was changed."
elif [ "$CHANGED" = 1 ] && [ "$DO_COMMIT" = 0 ]; then
  log "Synced. Review & commit in the dotfiles repo:"
  log "  git -C \"$DOTFILES_DIR\" add tmux.conf .config/tmux/ && git -C \"$DOTFILES_DIR\" commit && git -C \"$DOTFILES_DIR\" push"
  log "  (or re-run with --push to do it automatically)"
else
  log "Up to date."
fi
[ "$DO_RELOAD" = 1 ] || log "Reload a running tmux with:  tmux source-file ~/.tmux.conf   (or prefix+r)"
