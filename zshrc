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
plugins=(git common-aliases osx zsh-syntax-highlighting)

# User configuration

# Share zsh history across all open zsh sessions
setopt share_history
setopt extended_glob
setopt auto_cd

export PATH=$HOME/bin:/usr/local/bin:/usr/local/share/npm/bin:~/dev/api-sdk/bin/:$PATH
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

# You may need to manually set your language environment
export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi
#export EDITOR='/usr/local/bin/mvim -v'
export EDITOR='/usr/local/bin/nvim'

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

alias vim="/usr/local/bin/nvim"
alias vi=vim
alias tmux="TERM=screen-256color-bce tmux";
alias -s txt=vim
alias -s html=vim
alias -s vim=vim

alias easyget="curl -b ~/Dropbox/easynews.cookies.txt -v -L -O $1"
alias easyreget="curl -b ~/Dropbox/easynews.cookies.txt -C - -v -L -O $1"

# Start Z https://github.com/rupa/z
. `brew --prefix`/etc/profile.d/z.sh

source /Users/rowell/Dropbox/dev/base16-shell/base16-railscasts.dark.sh

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
bindkey '^r' history-incremental-search-backward

# Reduce the default 0.4 second lag when pressing the ESC key to .1
export KEYTIMEOUT=1

# Fix neovims handling of ctrl-h
infocmp $TERM | sed 's/kbs=^[hH]/kbs=\\177/' > $TERM.ti
tic $TERM.ti

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

# Set the shakti environment
export NODE_ENV=development
#########################

IPAD4WHITE_ESN='NFAPPL-D1-IPAD3=4-5E466F974D24EA3853A21720C67D64D3DA772EE7C991A01E2F4853FCC732BBEB'
FIT_SERVER_TEST='fit.us-west-2.dyntest.netflix.net:7101'
FIT_SERVER_PROD='fit.netflix.net:7101'
END_SUBSCRIBER_SESSION='v1/sessions/end'
BEGIN_SUBSCRIBER_SESSION='v1/sessions/new/s/subscriber'
subscriber-fail-test () {
    [ $# -eq 0 ] && FOO="esn=$IPAD4WHITE_ESN" || FOO="cid=$1"
    echo "$FIT_SERVER_TEST/$BEGIN_SUBSCRIBER_SESSION?$FOO"
    curl -i -X POST "$FIT_SERVER_TEST/$BEGIN_SUBSCRIBER_SESSION?$FOO" 
}
subscriber-restore-test () { 
    [ $# -eq 0 ] && FOO="esn=$IPAD4WHITE_ESN" || FOO="cid=$1"
    echo "$FIT_SERVER_TEST/$END_SUBSCRIBER_SESSION?$FOO"
    curl -i -X POST "$FIT_SERVER_TEST/$END_SUBSCRIBER_SESSION?$FOO" 
}
subscriber-fail-prod () { 
    [ $# -eq 0 ] && FOO="esn=$IPAD4WHITE_ESN" || FOO="cid=$1"
    echo "$FIT_SERVER_PROD/$BEGIN_SUBSCRIBER_SESSION?$FOO"
    curl -i -X POST "$FIT_SERVER_PROD/$BEGIN_SUBSCRIBER_SESSION?$FOO" 
}
subscriber-restore-prod () { 
    [ $# -eq 0 ] && FOO="esn=$IPAD4WHITE_ESN" || FOO="cid=$1"
    echo "$FIT_SERVER_PROD/$END_SUBSCRIBER_SESSION?$FOO"
    curl -i -X POST "$FIT_SERVER_PROD/$END_SUBSCRIBER_SESSION?$FOO" 
}

compilejstags () {
    for f ($1/(^node_modules/)#*.js*) { jsctags $f -f >> ./tags }
}

kubrickjstags () {
    for f (/Users/rowell/stash/kubrick/device/(^node_modules/)#*.js*) { jsctags $f -f >> ./tags }
}

# OPAM configuration
. /Users/rowell/.opam/opam-init/init.zsh > /dev/null 2> /dev/null || true
(which opam > /dev/null) && eval $(opam config env)

export NVM_DIR="/Users/rowell/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
