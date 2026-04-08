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

export MCFLY_KEY_SCHEME=vim
export MCFLY_FUZZY=2
export MCFLY_RESULTS=50
export MCFLY_INTERFACE_VIEW=BOTTOM
command -v mcfly &>/dev/null && eval "$(mcfly init zsh)"

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

# Find lines of code
loc() { find . -type f \( -name '*.js' -o -name '*.css' \) -not -path '.*node_modules*' | xargs wc -l }

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
