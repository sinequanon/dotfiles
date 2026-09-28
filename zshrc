# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
#ZSH_THEME="robbyrussell"
ZSH_THEME="avit"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git common-aliases zsh-syntax-highlighting)

# User configuration

# Share zsh history across all open zsh sessions
setopt share_history
setopt extended_glob
setopt auto_cd

export PATH=$PATH:$HOME/bin:/usr/local/bin:/usr/local/sbin

source $ZSH/oh-my-zsh.sh

command -v starship &>/dev/null && eval "$(starship init zsh)"

GRUVBOX_SHELL="$HOME/github/dotfiles/vim/bundle/gruvbox/gruvbox_256pallette_osx.sh"
[[ -s $GRUVBOX_SHELL ]] && source $GRUVBOX_SHELL

# You may need to manually set your language environment
export LANG=en_US.UTF-8

if [[ `uname` == 'Darwin' ]]; then
  alias ctags='`brew --prefix`/bin/ctags'
  . `brew --prefix`/etc/profile.d/z.sh
  export EDITOR='/opt/homebrew/bin/vim'
elif [[ `uname` == 'Linux' ]]; then
  # Start Z https://github.com/rupa/z
  export EDITOR='/usr/bin/vim'
  . ~/z.sh
fi

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
# if [ "$TERM" = "screen-256color" ] && [ -n "$TMUX" ]; then
#     alias vim="NVIM_TUI_ENABLE_TRUE_COLOR=1 /usr/local/bin/nvim"
# else
#     alias vim="/usr/local/bin/nvim"
# fi
alias vi=vim
alias -s txt=vim
alias -s html=vim
alias -s vim=vim
alias rm="trash"

alias ssh='TERM=xterm-256color ssh'

alias m3uget='f() { ffmpeg -user_agent "Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:82.0) Gecko/20100101 Firefox/82.0" -i $1 -c copy $2; };f'
alias example='f() { echo Your arg was $1. $2; };f'
alias glb='git lb'
alias gcpb='f() { git cherry-pick $(git merge-base $1 ${2})..$2; };f'
alias rebaser='git rebase -i "$(git merge-base origin/develop HEAD)"'
alias install='npm install --prefer-offline --no-audit'
alias photosrestorestat='log stream --predicate '\''process == "cloudd" or process == "cloudphotod" or process == "photolibraryd"'\'''

# Show processes keeping an external volume busy before ejecting it.
_volbusy() {
  if [[ $# -eq 0 ]]; then
    echo 'Usage: volbusy <volume-name-or-/Volumes/path>'
    echo 'Example: volbusy "My Passport"'
    return 2
  fi

  local volume="$*"
  local mount_path="$volume"
  [[ "$mount_path" == /* ]] || mount_path="/Volumes/$mount_path"

  if [[ ! -e "$mount_path" ]]; then
    echo "Volume not found: $mount_path"
    echo 'Available volumes:'
    command ls -1 /Volumes
    return 1
  fi

  sudo lsof -nP | command grep -F -- "$mount_path"
  local -a pipe_status=("${pipestatus[@]}")
  local lsof_status=${pipe_status[1]}
  local grep_status=${pipe_status[2]}
  if [[ $lsof_status -ne 0 ]]; then
    return $lsof_status
  fi
  if [[ $grep_status -eq 1 ]]; then
    echo "No open files found under $mount_path"
    return 0
  fi
  return $grep_status
}
alias volbusy='_volbusy'

# Find lines of code
loc() { find . -type f \( -name '*.js' -o -name '*.css' \) -not -path '.*node_modules*' | xargs wc -l }

# Port-forward a :work workspace. Defaults: rsotto/nq-aui-dgs, 1445:445
wpf() {
  local workspace="${1:-rsotto/proteus}"
  local ports="${2:-1445:445}"
  work port-forward --verbose "$workspace" --tcp "$ports"
}

# Unify all langs
LANG="en_US.UTF-8"
LC_COLLATE="en_US.UTF-8"
LC_CTYPE="en_US.UTF-8"
LC_MESSAGES="en_US.UTF-8"
LC_MONETARY="en_US.UTF-8"
LC_NUMERIC="en_US.UTF-8"
LC_TIME="en_US.UTF-8"
LC_ALL="en_US.UTF-8"

bindkey -v

bindkey '^P' up-history
bindkey '^N' down-history
bindkey '^?' backward-delete-char
bindkey '^h' backward-delete-char
bindkey '^w' backward-kill-word
# Remove the binding key so mcfly can work
# bindkey '^r' history-incremental-search-backward

# Reduce the default 0.4 second lag when pressing the ESC key to .1
export KEYTIMEOUT=1

export MCFLY_KEY_SCHEME=vim
export MCFLY_FUZZY=2
export MCFLY_RESULTS=50
export MCFLY_INTERFACE_VIEW=BOTTOM
command -v mcfly &>/dev/null && eval "$(mcfly init zsh)"

# Fix neovims handling of ctrl-h
# infocmp $TERM | sed 's/kbs=^[hH]/kbs=\\177/' > $TERM.ti
# tic $TERM.ti

# Give iterm the ability to display font italics
# https://disqus.com/home/discussion/alexpearce/enabling_italic_fonts_in_iterm_2_tmux_and_vim_19/#comment-2508208541
#{ infocmp -1 xterm-256color ; echo -e "\tsitm=\\E[3m,\n\tritm=\\E[23m,"; } > xterm-256color.terminfo
#tic xterm-256color.terminfo

#
# Press ctrl-z to put a task into background, then ctrl-z again to get into foreground
fancy-ctrl-z () {
    if [[ $#BUFFER -eq 0 ]]; then
        BUFFER="fg"
        zle accept-line
    else
        zle push-input
        zle clear-screen
    fi
}
zle -N fancy-ctrl-z
bindkey '^Z' fancy-ctrl-z

export PATH="$PATH:$HOME/.config/yarn/global/node_modules/.bin"

if type brew &>/dev/null; then
  FPATH=$(brew --prefix)/share/zsh-completions:$FPATH
fi

ulimit -n 65536 65536

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

alias python="python3"

# List printers
listprn() {
  for printer in $(lpstat -p|awk '{print $2}'); do; case "$printer" in TPAC*) echo "$printer"; esac;done;
}

export PATH="/usr/local/opt/curl/bin:/usr/local/opt/gnu-sed/libexec/gnubin:$PATH"

# Fix homebrew node upgrade
ulimit -Sf unlimited

# Change tab or window name in kitty
precmd () {print -Pn "\e]0;%~\a"}

export NEWT_SKIP_VPNCHECK=1

# user-local binaries
export PATH="$HOME/.local/bin:$PATH"

# pi-stall-guard: every normal interactive `pi` launch has an independent
# supervisor. It warns and aborts silent tools, then recovers a frozen Pi or an
# uncooperative tool by reopening the persisted session. `command pi` remains an
# explicit opt-out for one-off commands.
# The guard starts only when its managed diagnostic script is installed.
pi() {
  emulate -L zsh
  # Propagate the persisted Agent Beach profile into Pi's environment so
  # JSON-mode subagents inherit it instead of falling back to `rpc`.
  local selected_agent_beach_profile="${AGENT_BEACH_PROFILE:-}"

  if [[ -z "$selected_agent_beach_profile" ]]; then
    local agent_beach_profile_file="${HOME}/.pi/agent/agent-beach/profile.json"

    if [[ -r "$agent_beach_profile_file" ]]; then
      selected_agent_beach_profile="$(
        jq -er '
          .profile
          | select(
              type == "string"
              and test("^[A-Za-z0-9._-]+$")
            )
        ' "$agent_beach_profile_file" 2>/dev/null
      )" || {
        print -u2 \
          "pi: invalid Agent Beach profile in ${agent_beach_profile_file}"
        return 1
      }
    fi
  fi

  if [[ -n "$selected_agent_beach_profile" ]]; then
    local -x AGENT_BEACH_PROFILE="$selected_agent_beach_profile"
  fi

  local guard="$HOME/.pi/diag/pi-stall-guard.mjs" heartbeat_ext="$HOME/.pi/agent/extensions/stall-guard/index.ts" arg next_mode=0 parsed_mode=""
  if [[ ! -t 0 || ! -t 1 ]]; then
    command pi "$@"
    return
  fi
  for arg in "$@"; do
    if (( next_mode )); then
      next_mode=0
      case "$arg" in
        text|json|rpc) parsed_mode="$arg" ;;
      esac
      continue
    fi
    case "$arg" in
      --mode) next_mode=1 ;;
      -p|--print|-ne|--no-extensions|--no-session|--export|--list-models|-h|--help|-v|--version)
        command pi "$@"
        return
        ;;
    esac
  done
  if [[ "$parsed_mode" == "json" || "$parsed_mode" == "rpc" ]]; then
    command pi "$@"
    return
  fi
  case "${1:-}" in
    auth|install|remove|uninstall|update|list|config)
      command pi "$@"
      return
      ;;
  esac
  if [[ ! -r "$guard" || ! -r "$heartbeat_ext" ]]; then
    command pi "$@"
    return
  fi
  if (( ! $+commands[node] )); then
    print -u2 "pi-stall-guard: node is unavailable; starting Pi without supervision."
    command pi "$@"
    return
  fi
  command node "$guard" "$@"
}

# pi-update: run `pi update` (forwarding all flags), then reapply the flicker fix.
# The flicker fix is idempotent -- a no-op if pi wasn't reinstalled / already patched.
#   pi-update               # update pi core, then reapply flicker fix
#   pi-update --extensions  # update installed extensions/packages only
#   pi-update --all         # update pi + extensions, then reapply
#   pi-update --self        # update pi only
#   pi-update npm:@foo/bar  # update a single package
pi-update() {
  local pi_bin c
  # `pi` is normally the supervised shell function above; resolve the actual
  # executable so this maintenance command does not recurse through the guard.
  pi_bin="$(whence -p pi 2>/dev/null)"
  if [[ -z "$pi_bin" ]]; then
    # pi may be installed under an nvm node version that is not the active one on PATH
    for c in "$HOME"/.nvm/versions/node/*/bin/pi(N) /usr/local/bin/pi /opt/homebrew/bin/pi; do
      [[ -x "$c" ]] && pi_bin="$c" && break
    done
  fi
  if [[ -z "$pi_bin" ]]; then
    print -u2 "pi-update: could not find the pi binary (is pi installed?)."
    return 1
  fi
  # Run with pi's own bin dir on PATH so the matching node/npm are available to the self-update.
  PATH="${pi_bin:h}:$PATH" "$pi_bin" update "$@" || return $?
  pi-flicker-fix
}
