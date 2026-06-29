#!/usr/bin/env bash
# Shared file/process icon classifier for the tmux pane-overview scripts.
# SOURCE this file (don't run it); it defines pane_icon and ICON_RESULT.
#
# pane_icon <command> <full-path> -> sets ICON_RESULT to a 2-cell emoji that
# reflects the running process, or — for editors / shells / JS runtimes — the
# project type detected from the directory (à la starship: tsconfig.json -> TS,
# pom.xml -> Java, Cargo.toml -> Rust, ...). All icons are 2 cells wide so the
# columns stay aligned ("  " = unknown). Pure bash (only `[ -e ]` tests), so it
# is cheap to call per pane.

ICON_RESULT='  '

pane_icon() {
  local cmd="$1" path="$2" d
  # Definitive process types win regardless of directory.
  case "$cmd" in
    pi|codex|claude|aider|llm|ollama|cursor)            ICON_RESULT='🤖'; return ;;
    ssh|mosh|et|sshpass)                                ICON_RESULT='🔐'; return ;;
    docker|docker-compose|lazydocker|podman)            ICON_RESULT='🐳'; return ;;
    kubectl|k9s|helm|kubie)                             ICON_RESULT='🚢'; return ;;
    git|lazygit|gitui|tig|gh)                           ICON_RESULT='🌿'; return ;;
    psql|mysql|sqlite3|redis-cli|mongo|mongosh|pgcli)   ICON_RESULT='🐘'; return ;;
    htop|top|btop|btm|glances|gotop)                    ICON_RESULT='📊'; return ;;
    man|less|bat|more|most)                             ICON_RESULT='📖'; return ;;
    python|python3|ipython|py|pytest)                   ICON_RESULT='🐍'; return ;;
    ruby|irb|rails|rake)                                ICON_RESULT='💎'; return ;;
    cargo|rustc)                                        ICON_RESULT='🦀'; return ;;
    go|gopls)                                           ICON_RESULT='🐹'; return ;;
    java|mvn|gradle|gradlew|kotlin)                     ICON_RESULT='☕'; return ;;
    lua|luajit)                                         ICON_RESULT='🌙'; return ;;
  esac
  # Editors / shells / JS runtimes: detect the project type from the directory,
  # walking up to (and stopping at) the git root.
  case "$cmd" in
    nvim|vim|vi|view|hx|helix|emacs|nano|micro|kak|code|zed|node|deno|bun|npm|pnpm|yarn|npx|tsx|ts-node|zsh|bash|sh|fish|dash|ksh)
      d="$path"
      while [ -n "$d" ]; do
        if   [ -e "$d/tsconfig.json" ];                                                      then ICON_RESULT='🟦'; return
        elif [ -e "$d/deno.json" ] || [ -e "$d/deno.jsonc" ];                                then ICON_RESULT='🦕'; return
        elif [ -e "$d/package.json" ];                                                       then ICON_RESULT='🟨'; return
        elif [ -e "$d/Cargo.toml" ];                                                         then ICON_RESULT='🦀'; return
        elif [ -e "$d/go.mod" ];                                                             then ICON_RESULT='🐹'; return
        elif [ -e "$d/pom.xml" ] || [ -e "$d/build.gradle" ] || [ -e "$d/build.gradle.kts" ]; then ICON_RESULT='☕'; return
        elif [ -e "$d/pyproject.toml" ] || [ -e "$d/requirements.txt" ] || [ -e "$d/setup.py" ] || [ -e "$d/Pipfile" ]; then ICON_RESULT='🐍'; return
        elif [ -e "$d/Gemfile" ];                                                            then ICON_RESULT='💎'; return
        elif [ -e "$d/mix.exs" ];                                                            then ICON_RESULT='💧'; return
        elif [ -e "$d/CMakeLists.txt" ] || [ -e "$d/Makefile" ];                             then ICON_RESULT='🔧'; return
        elif [ -e "$d/.git" ];                                                               then break
        fi
        case "$d" in */*) d="${d%/*}" ;; *) break ;; esac
      done
      case "$cmd" in
        node|deno|bun|npm|pnpm|yarn|npx|tsx|ts-node) ICON_RESULT='🟢' ;;  # JS runtime, no project marker
        zsh|bash|sh|fish|dash|ksh)                   ICON_RESULT='🐚' ;;
        *)                                           ICON_RESULT='📝' ;;  # editor
      esac
      return ;;
  esac
  ICON_RESULT='  '
}
