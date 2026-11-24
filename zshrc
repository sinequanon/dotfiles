# Resolve the checkout from the installed ~/.zshrc symlink once so runtime
# helpers work on both the Linux and macOS checkout locations (or any clone).
if [[ -z "${DOTFILES_DIR:-}" ]]; then
  typeset _dotfiles_source="$HOME/.zshrc" _dotfiles_target _dotfiles_dir
  integer _dotfiles_link_hops=0
  while [[ -L "$_dotfiles_source" && $_dotfiles_link_hops -lt 16 ]]; do
    (( _dotfiles_link_hops += 1 ))
    _dotfiles_dir="$(cd "${_dotfiles_source:h}" && pwd -P)" || break
    _dotfiles_target="$(readlink "$_dotfiles_source")" || break
    if [[ "$_dotfiles_target" = /* ]]; then
      _dotfiles_source="$_dotfiles_target"
    else
      _dotfiles_source="$_dotfiles_dir/$_dotfiles_target"
    fi
  done
  _dotfiles_dir="${_dotfiles_source:h}"
  [[ -d "$_dotfiles_dir/scripts" && -d "$_dotfiles_dir/installers" ]] && export DOTFILES_DIR="$_dotfiles_dir"
fi
: "${DOTFILES_DIR:=$HOME/.config/work/dotfiles}"

export term=xterm-256color
export colorterm=TRUECOLOR

# Codex desktop imports an interactive shell's environment; read only its bridge key.
if [[ -r "$HOME/.codex/.env" ]]; then
  export CODEX_MODEL_BRIDGE_API_KEY="$(
    /usr/bin/awk '/^CODEX_MODEL_BRIDGE_API_KEY=/ { sub(/^[^=]*=/, ""); print; exit }' "$HOME/.codex/.env"
  )"
fi

# Path to your oh-my-zsh installation.
export ZSH=$HOME/.oh-my-zsh

# Set name of the theme to load.
# Look in ~/.oh-my-zsh/themes/
# Optionally, if you set this to "random", it'll load a random theme each
# time that oh-my-zsh is loaded.
#ZSH_THEME="robbyrussell"
ZSH_THEME="avit"

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to disable bi-weekly auto-update checks.
# DISABLE_AUTO_UPDATE="true"

# Uncomment the following line to change how often to auto-update (in days).
# export UPDATE_ZSH_DAYS=13

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# The optional three formats: "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

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

export PATH=$PATH:$HOME/bin:$HOME/.local/bin:/usr/local/bin:/usr/local/sbin

# Load oh-my-zsh only if it's actually installed, so a fresh workspace whose
# installer hasn't finished (or failed to fetch it) still gets a working shell
# instead of "no such file or directory: .../oh-my-zsh.sh" on every login.
[[ -r "$ZSH/oh-my-zsh.sh" ]] && source "$ZSH/oh-my-zsh.sh"

command -v starship &>/dev/null && eval "$(starship init zsh)"

GRUVBOX_SHELL="$HOME/github/dotfiles/vim/bundle/gruvbox/gruvbox_256pallette_osx.sh"
[[ -s $GRUVBOX_SHELL ]] && source $GRUVBOX_SHELL

# You may need to manually set your language environment
export LANG=en_US.UTF-8

if [[ "$(uname)" == 'Darwin' ]]; then
  if (( $+commands[brew] )); then
    typeset _dotfiles_brew_prefix
    _dotfiles_brew_prefix="$(brew --prefix)"
    alias ctags="$_dotfiles_brew_prefix/bin/ctags"
    [[ -r "$_dotfiles_brew_prefix/etc/profile.d/z.sh" ]] && source "$_dotfiles_brew_prefix/etc/profile.d/z.sh"
  fi
  export EDITOR="$(command -v vim 2>/dev/null || print /usr/bin/vim)"
elif [[ "$(uname)" == 'Linux' ]]; then
  # Start Z https://github.com/rupa/z
  export EDITOR='/usr/bin/vim'
  [[ -s ~/.local/share/z/z.sh ]] && . ~/.local/share/z/z.sh
fi

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi
#export EDITOR='/usr/local/bin/mvim -v'

if grep -qE "(Microsoft|WS)" /proc/version &> /dev/null ; then
  WSL=true
else
  WSL=false
fi
if [[ $WSL == true ]]; then
  # Prevent zsh in WSL from complaining
  unsetopt BG_NICE
fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# ssh
# export SSH_KEY_PATH="~/.ssh/dsa_id"

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

# Compress recordings for Slack without resizing them or replacing originals.
_slackvideo() {
  emulate -L zsh
  if (( $# == 0 )); then
    print -u2 -- 'Usage: slackvideo <recording> [recording ...]'
    return 2
  fi
  if (( ! $+commands[ffmpeg] )); then
    print -u2 -- 'slackvideo: ffmpeg is required (macOS: brew install ffmpeg)'
    return 1
  fi

  local input output staging
  for input in "$@"; do
    input="${input:a}"
    if [[ ! -f "$input" ]]; then
      print -u2 -- "slackvideo: file not found: $input"
      return 1
    fi
    output="${input:h}/Slack/${input:t:r}.mp4"
    if [[ -e "$output" || -L "$output" ]]; then
      print -r -- "Skipping existing output: $output"
      continue
    fi
    command mkdir -p -- "${output:h}" || return
    staging="$(command mktemp "${output:h}/.slackvideo.XXXXXX")" || return
    {
      command ffmpeg -hide_banner -nostdin -y -i "$input" \
        -map 0:v:0 -map '0:a?' -map_metadata -1 \
        -c:v libx264 -preset slow -crf 20 -threads 8 -pix_fmt yuv420p \
        -fps_mode vfr -enc_time_base demux \
        -c:a aac -b:a 128k -movflags +faststart -f mp4 "$staging" || return
      # Publish only completed files; ln refuses to replace an existing output.
      command ln -- "$staging" "$output" || return
    } always {
      command rm -f -- "$staging"
    }
    print -r -- "Saved: $output"
  done
  return 0
}
alias slackvideo='_slackvideo'

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

# McFly - shell history search
if command -v mcfly &>/dev/null; then
export MCFLY_KEY_SCHEME=vim
export MCFLY_FUZZY=2
export MCFLY_RESULTS=50
export MCFLY_INTERFACE_VIEW=BOTTOM
  export MCFLY_DEBUG="${MCFLY_DEBUG:-}"
  eval "$(mcfly init zsh)"
  bindkey -M viins '^R' mcfly-history-widget
  bindkey -M vicmd '^R' mcfly-history-widget
  bindkey -M emacs '^R' mcfly-history-widget
else
  bindkey '^r' history-incremental-search-backward
fi

# Reduce the default 0.4 second lag when pressing the ESC key to .1
export KEYTIMEOUT=1

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

# The Netflix claude launcher execs into a version-pinned binary
# (~/.local/share/claude/versions/X.Y.Z), so /proc sees that version string
# as the process name instead of "claude". Herdr's foreground-agent
# detection only recognizes the literal name, so it identifies the pane as
# Claude for a few seconds at launch and then drops it back to no agent on
# its next reconcile, which is why Claude panes vanish from the herdr
# sidebar shortly after starting. HERDR_AGENT is herdr's documented hint
# for agents hidden behind a wrapper/launcher; scope it to this function so
# it doesn't mislabel anything else run in the same pane.
# /etc/zsh/zshrc aliases claude to a `newt --app-type=...` wrapper we don't
# own. zsh can't define a function over an existing alias of the same name,
# so capture whatever that alias currently expands to and rebuild it as a
# function with HERDR_AGENT added. Falls back to a plain `command claude`
# if the alias is ever removed.
# NOTE: this must not use `claude() { ... }` function syntax anywhere below,
# even in a branch that won't run. `claude` is still an active alias at this
# point in a sourced file, and zsh resolves aliases while parsing the whole
# if/fi block, before any of it executes, regardless of which branch is
# actually taken. `functions[claude]=...` assignment avoids that entirely.
if (( ${+aliases[claude]} )); then
  __claude_wrap=$aliases[claude]
else
  __claude_wrap="command claude"
fi
unalias claude 2>/dev/null
functions[claude]="HERDR_AGENT=claude ${__claude_wrap} \"\$@\""
unset __claude_wrap

# Preserve the installed Codex launcher without requiring Newt on personal hosts.
# Keep an existing function on reload, after its original alias was consumed.
if (( ${+aliases[codex]} || ! ${+functions[codex]} )); then
  if (( ${+aliases[codex]} )); then
    __codex_wrap=$aliases[codex]
    if [[ $__codex_wrap == 'newt --app-type=coding-assistant exec '* && $__codex_wrap != *'--param HERDR_AGENT=codex'* ]]; then
      __codex_wrap=${__codex_wrap/ exec / exec --param HERDR_AGENT=codex }
    fi
  else
    __codex_wrap="command codex"
  fi
  unalias codex 2>/dev/null || true
  functions[codex]="HERDR_AGENT=codex ${__codex_wrap} \"\$@\""
  unset __codex_wrap
fi
# Cancel a test membership immediately, then deactivate its MOP or expire its primary card.
former-nomop() {
  emulate -L zsh
  setopt extended_glob
  if (( $# < 1 || $# > 2 )) || [[ "${2-}" != "" && "${2-}" != --expired ]]; then
    print -u2 -- 'Usage: former-nomop <cid-or-email> [--expired] (cancel membership, then deactivate MOP or expire primary card in test)'
    return 2
  fi

  local account="$1" mop_option="${2-}" cid payload response dependency
  for dependency in metatron jq; do
    if (( ! $+commands[$dependency] )); then
      print -u2 -- "former-nomop: required command not found: $dependency"
      return 1
    fi
  done

  if [[ "$account" == <-> && "$account" == *[1-9]* ]]; then
    cid="$account"
  elif [[ "$account" == ?*@?* ]]; then
    payload="$(command jq -nc --arg email "$account" '{email: $email}')" || return
    response="$(command metatron -n curl -a venkman -f -timeout 10s \
      'https://venkman.cluster.us-east-1.test.cloud.netflix.net:8443/grpc/venkman/com.netflix.venkman.VenkmanService/GetSubscriberInfoByEmail' \
      -X POST -H 'Content-Type: application/json' -d "$payload")" || return

    # Keep int64 CIDs exact; reject numeric responses beyond jq's safe range.
    cid="$(print -r -- "$response" | command jq -er '
      select((.error // "") == "") | .subscriberInfo.customerId
      | if type == "string" then .
        elif type == "number" and . > 0 and . <= 9007199254740991 and . == floor
        then tostring else empty end
      | select(test("^[0-9]+$") and test("[1-9]"))
    ')" || {
      print -u2 -- "former-nomop: could not resolve a valid CID for $account in test"
      return 1
    }
  else
    print -u2 -- 'former-nomop: provide a positive numeric CID or an email address'
    return 2
  fi

  # Strip leading zeros without converting the CID to a floating-point number.
  cid="${cid##0#}"
  payload="$(command jq -nc --arg cid "$cid" \
    '{cid: $cid, deferred: false, cancelReason: "CUSTOMER_REQUEST"}')" || return
  response="$(command metatron -n curl -a mediator -f -timeout 10s \
    'https://mediator-int.cluster.us-east-1.test.cloud.netflix.net:8443/grpc/mediator/com.netflix.mediator.MediatorService/CancelMembership' \
    -X POST -H 'Content-Type: application/json' -d "$payload")" || {
    print -u2 -- 'former-nomop: cancellation request failed; membership state is unconfirmed. MOP update was not attempted.'
    return 1
  }
  if ! print -r -- "$response" | command jq -e --arg cid "$cid" '
    (.cid | tostring) == $cid
    and (.error.errCode // "") == ""
    and (.error.errMsg // "") == ""
  ' >/dev/null; then
    print -u2 -- "former-nomop: cancellation was not confirmed; MOP update was not attempted: $response"
    return 1
  fi
  print -r -- "former-nomop: Mediator reported successful immediate cancellation for CID $cid (test)"

  if [[ "$mop_option" == --expired ]]; then
    payload="$(command jq -nc --arg cid "$cid" \
      '{customerId: $cid, expirationYear: 2000, expirationMonth: 1}')" || return
    response="$(command metatron -n curl -a minter -f -timeout 10s \
      'https://minter.cluster.us-east-1.test.cloud.netflix.net:8443/grpc/minter/com.netflix.minter.MinterService/modifyCCExpiration' \
      -X POST -H 'Content-Type: application/json' -d "$payload")" || {
      print -u2 -- 'former-nomop: cancellation succeeded, but primary-card expiration update is unconfirmed.'
      return 1
    }
    if ! print -r -- "$response" | command jq -e '.success == true' >/dev/null; then
      print -u2 -- "former-nomop: cancellation succeeded, but Minter did not report a successful primary-card expiration update: $response"
      return 1
    fi
    print -r -- "former-nomop: Minter reported successful primary-card expiration update to 2000-01 for CID $cid (test)"
    print -r -- 'former-nomop: this API leaves India and South Korea cards unchanged, even when it reports success.'
    return 0
  fi

  payload="$(command jq -nc --arg cid "$cid" '{cid: $cid, isForceNoMop: true}')" || return
  response="$(command metatron -n curl -a minter -f -timeout 10s \
    'https://minter.cluster.us-east-1.test.cloud.netflix.net:8443/grpc/minter/com.netflix.minter.MinterService/deactivateMop' \
    -X POST -H 'Content-Type: application/json' -d "$payload")" || {
    print -u2 -- 'former-nomop: cancellation succeeded, but MOP deactivation is unconfirmed.'
    return 1
  }

  if ! print -r -- "$response" | command jq -e '.resultCode == "SUCCESS"' >/dev/null; then
    print -u2 -- "former-nomop: cancellation succeeded, but Minter did not report successful MOP deactivation: $response"
    return 1
  fi
  print -r -- "former-nomop: Minter reported successful MOP deactivation for CID $cid (test)"
}
