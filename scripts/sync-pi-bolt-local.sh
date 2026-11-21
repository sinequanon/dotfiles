#!/usr/bin/env bash
# sync-pi-bolt-local.sh — sync pi-bolt-local configuration from work.dotfiles
# into this (personal) dotfiles repo, then link into ~/.pi-bolt-local/agent/
#
# On a machine without the work dotfiles repo, run with --link-only to just
# relink files that are already in this repo's .pi-bolt-local/ into $HOME.
#
# Usage: sync-pi-bolt-local.sh [-n|--dry-run] [--link-only] [--pull] [--reload]
#                              [--commit] [--push] [-h|--help]
#   -n, --dry-run   print what would change; modify nothing
#       --link-only skip work-repo sync; only relink this repo's .pi-bolt-local/* into $HOME
#       --pull      git pull work.dotfiles first (needs network + creds)
#       --reload    reload pi-bolt after syncing/linking
#       --commit    stage and commit files in this repo
#       --push      implies --commit, then push
#   -h, --help      show this help
#
# Default: sync files + relink + validate. No git.

set -euo pipefail

usage() { sed -n '2,/^set -euo/p' "$0" | sed '$d; s/^#\{0,1\} \{0,1\}//'; }

DRY=0; DO_PULL=0; DO_RELOAD=0; DO_COMMIT=0; DO_PUSH=0; LINK_ONLY=0
while [ $# -gt 0 ]; do
  case "$1" in
    -n|--dry-run)  DRY=1 ;;
    --link-only)   LINK_ONLY=1 ;;
    --pull)        DO_PULL=1 ;;
    --reload)      DO_RELOAD=1 ;;
    --commit)      DO_COMMIT=1 ;;
    --push)        DO_COMMIT=1; DO_PUSH=1 ;;
    -h|--help)     usage; exit 0 ;;
    *) printf 'unknown option: %s (try --help)\n' "$1" >&2; exit 2 ;;
  esac
  shift
done

log()  { printf '%s\n' "$*"; }
info() { printf '  %s\n' "$*"; }
warn() { printf 'warning: %s\n' "$*" >&2; }
die()  { printf 'error: %s\n' "$*" >&2; exit 1; }

if [ "$LINK_ONLY" = 1 ] && { [ "$DO_PULL" = 1 ] || [ "$DO_COMMIT" = 1 ] || [ "$DO_PUSH" = 1 ]; }; then
  warn "--link-only only relinks \$HOME; ignoring --pull/--commit/--push"
  DO_PULL=0; DO_COMMIT=0; DO_PUSH=0
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
DOTFILES_DIR="$(git -C "$SCRIPT_DIR" rev-parse --show-toplevel 2>/dev/null || dirname "$SCRIPT_DIR")"
WORK_DIR="${WORK_DOTFILES_DIR:-$HOME/github/work.dotfiles}"

[ -d "$DOTFILES_DIR" ] || die "dotfiles repo not found: $DOTFILES_DIR"

# Work repo only needed for sync (not --link-only)
if [ "$LINK_ONLY" = 0 ]; then
  [ -d "$WORK_DIR" ] || die "work dotfiles repo not found: $WORK_DIR (set WORK_DOTFILES_DIR)"
fi

CHANGED=0; LINKED=0

# Copy one file if different, honoring --dry-run
sync_file() {
  local src="$1" dest="$2" rel="$3"
  [ -e "$src" ] || { warn "source missing, skipping: $src"; return 0; }
  cmp -s "$src" "$dest" 2>/dev/null && return 0
  if [ -e "$dest" ]; then info "update  $rel"; else info "add     $rel"; fi
  CHANGED=1
  [ "$DRY" = 1 ] && return 0
  mkdir -p "$(dirname "$dest")"
  cp -f "$src" "$dest"
}

# Copy entire directory (add/update, remove deleted files)
sync_dir() {
  local srcd="$1" destd="$2" relp="$3"
  [ "$DRY" = 1 ] || mkdir -p "$destd"
  shopt -s nullglob
  for f in "$srcd"/*; do
    base="${f##*/}"
    [ -d "$f" ] && continue
    sync_file "$f" "$destd/$base" "$relp/$base"
  done
  for f in "$destd"/*; do
    base="${f##*/}"
    [ -d "$f" ] && continue
    if [ ! -e "$srcd/$base" ]; then
      info "delete  $relp/$base"
      CHANGED=1
      [ "$DRY" = 1 ] || rm -f "$f"
    fi
  done
  shopt -u nullglob
}

# Idempotently symlink dest -> src, backing up existing files
link_file() {
  local src="$1" dest="$2" mode="$3"
  [ -e "$src" ] || { warn "link source missing, skipping: $src"; return 0; }
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    [ "$DRY" = 1 ] || chmod "$mode" "$src" 2>/dev/null || true
    return 0
  fi
  if [ -L "$dest" ]; then info "relink  $dest -> $src (was $(readlink "$dest"))"
  elif [ -e "$dest" ]; then
    if [ -d "$dest" ]; then
      info "link    $dest -> $src (existing directory backed up)"
    else
      info "link    $dest -> $src (existing file backed up)"
    fi
  else info "link    $dest -> $src"
  fi
  LINKED=1
  [ "$DRY" = 1 ] && return 0
  chmod "$mode" "$src" 2>/dev/null || true
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ]; then
    ln -sfn "$src" "$dest"
  elif [ -e "$dest" ]; then
    if [ -d "$dest" ]; then
      # Remove and recreate as symlink for directories
      rm -rf "$dest"
    else
      if cmp -s "$src" "$dest"; then rm -f "$dest"
      else mv "$dest" "$dest.bak.$(date +%s)"; fi
    fi
    ln -s "$src" "$dest"
  else
    ln -s "$src" "$dest"
  fi
}

# Sync from work.dotfiles (if available)
if [ "$LINK_ONLY" = 0 ]; then
  WORK_HEAD="$(git -C "$WORK_DIR" rev-parse --short HEAD 2>/dev/null || echo '?')"
  log "pi-bolt-local sync:  $WORK_DIR  ->  $DOTFILES_DIR"
  log "work HEAD: $WORK_HEAD"

  if [ "$DO_PULL" = 1 ]; then
    log ""; log "==> pull work repo"
    [ "$DRY" = 1 ] || git -C "$WORK_DIR" pull --ff-only
    WORK_HEAD="$(git -C "$WORK_DIR" rev-parse --short HEAD 2>/dev/null || echo '?')"
  fi

  log ""; log "==> files"
  sync_file "$WORK_DIR/.pi-bolt-local/agent/extensions/statusline.ts" "$DOTFILES_DIR/.pi-bolt-local/agent/extensions/statusline.ts" ".pi-bolt-local/agent/extensions/statusline.ts"
  sync_file "$WORK_DIR/.pi-bolt-local/agent/AGENTS.md" "$DOTFILES_DIR/.pi-bolt-local/agent/AGENTS.md" ".pi-bolt-local/agent/AGENTS.md"
  sync_file "$WORK_DIR/.pi-bolt-local/agent/settings.json" "$DOTFILES_DIR/.pi-bolt-local/agent/settings.json" ".pi-bolt-local/agent/settings.json"
  sync_dir  "$WORK_DIR/.pi-bolt-local/agent/skills" "$DOTFILES_DIR/.pi-bolt-local/agent/skills" ".pi-bolt-local/agent/skills"
  [ "$CHANGED" = 0 ] && info "(no file changes)"
fi

# Link into ~/.pi-bolt-local/agent/
if [ -d "$HOME/.pi-bolt-local" ] || [ "$DRY" = 1 ]; then
  log ""; log "==> live links"
  link_file "$DOTFILES_DIR/.pi-bolt-local/agent/extensions/statusline.ts" "$HOME/.pi-bolt-local/agent/extensions/statusline.ts" 0644
  link_file "$DOTFILES_DIR/.pi-bolt-local/agent/AGENTS.md" "$HOME/.pi-bolt-local/agent/AGENTS.md" 0644
  link_file "$DOTFILES_DIR/.pi-bolt-local/agent/settings.json" "$HOME/.pi-bolt-local/agent/settings.json" 0644
  link_file "$DOTFILES_DIR/.pi-bolt-local/agent/skills/humanizer" "$HOME/.pi-bolt-local/agent/skills/humanizer" 0755
  link_file "$DOTFILES_DIR/.pi-bolt-local/agent/skills/no-ai-slop" "$HOME/.pi-bolt-local/agent/skills/no-ai-slop" 0755
  [ "$LINKED" = 0 ] && info "(all links already current)"
fi

# Validate
if [ "$DRY" = 0 ]; then
  log ""; log "==> validate"
  [ -f "$DOTFILES_DIR/.pi-bolt-local/agent/AGENTS.md" ] && info "AGENTS.md exists"
  [ -f "$DOTFILES_DIR/.pi-bolt-local/agent/settings.json" ] && info "settings.json exists"
  [ -f "$DOTFILES_DIR/.pi-bolt-local/agent/extensions/statusline.ts" ] && info "statusline.ts exists"
  [ -d "$DOTFILES_DIR/.pi-bolt-local/agent/skills/humanizer" ] && info "humanizer skill exists"
  [ -d "$DOTFILES_DIR/.pi-bolt-local/agent/skills/no-ai-slop" ] && info "no-ai-slop skill exists"
fi

# Reload pi-bolt
if [ "$DO_RELOAD" = 1 ]; then
  log ""; log "==> reload"
  [ "$DRY" = 1 ] || command -v pi >/dev/null 2>&1 && pi reload && info "pi-bolt reloaded"
fi

# Git operations
if [ "$DO_COMMIT" = 1 ]; then
  log ""; log "==> git"
  [ "$DRY" = 1 ] || {
    git -C "$DOTFILES_DIR" add .pi-bolt-local/
    if git -C "$DOTFILES_DIR" diff --cached --quiet; then
      info "nothing staged to commit"
    else
      git -C "$DOTFILES_DIR" commit -m "pi-bolt-local: sync from work.dotfiles ($WORK_HEAD)"
      info "committed"
      [ "$DO_PUSH" = 1 ] && { git -C "$DOTFILES_DIR" push && info "pushed"; }
    fi
  }
fi

# Summary
if [ "$DRY" = 1 ]; then
  log ""; log "Dry run only — nothing was changed."
elif [ "$LINK_ONLY" = 1 ]; then
  if [ "$LINKED" = 1 ]; then log "Linked pi-bolt-local into \$HOME."; else log "All links already current."; fi
elif [ "$CHANGED" = 1 ] && [ "$DO_COMMIT" = 0 ]; then
  log ""; log "Synced. Review & commit in the dotfiles repo:"
  log "  git -C \"$DOTFILES_DIR\" add .pi-bolt-local/ && git -C \"$DOTFILES_DIR\" commit && git -C \"$DOTFILES_DIR\" push"
  log "  (or re-run with --push to do it automatically)"
else
  log ""; log "Up to date."
fi
[ "$DO_RELOAD" = 1 ] || log "Reload pi-bolt with:  pi reload"
