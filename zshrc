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
plugins=(git common-aliases gulp zsh-syntax-highlighting docker)

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
if [[ `uname` == 'Darwin' ]]; then
  export EDITOR='/usr/local/bin/vim'
elif [[ `uname` == 'Linux' ]]; then
  export EDITOR='/usr/bin/vim'
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
# alias tmux="TERM=screen-256color tmux";
alias -s txt=vim
alias -s html=vim
alias -s vim=vim

alias jshakti="pkill gulp; gulp js && shakti"
alias ashakti="pkill gulp; gulp assets && shakti"
alias cshakti="pkill gulp; gulp clearCache && gulp clean && gulp locales && gulp assets && shakti"

alias easyget="curl -b ~/Dropbox/easynews.cookies.txt -v -L -O $1"
alias easyreget="curl -b ~/Dropbox/easynews.cookies.txt -C - -v -L -O $1"

alias rm="trash"

#Postgres Aliases
alias palpha='psql --host=prequel-dev.curho7ugte77.us-west-2.rds.amazonaws.com --username=prequel_dev prequel_alpha'
alias pbeta='psql --host=prequelbeta.cjrtfdmnhffu.us-west-2.rds.amazonaws.com --username=prequel_dev prequel_dev'
alias pprod='psql --host=prequel-prod.cjrtfdmnhffu.us-west-2.rds.amazonaws.com --username=prequel prequel_prod'
alias plocal='psql --host=127.0.0.1 --username=postgres cia-prequel-api_development'

alias ssh='TERM=xterm-256color ssh'

if [[ `uname` == 'Darwin' ]]; then
  alias ctags='`brew --prefix`/bin/ctags'
fi

# Find lines of code
loc() { find . -type f \( -name '*.js' -o -name '*.css' \) -not -path '.*node_modules*' | xargs wc -l }

# Start Z https://github.com/rupa/z
if [[ `uname` == 'Darwin' ]]; then
. `brew --prefix`/etc/profile.d/z.sh
elif [[ `uname` == 'Linux' ]]; then
. ~/z.sh
fi

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

# Set the shakti environment
export NODE_ENV=local

# Set hybrid-material colors
BASE16_SHELL="$HOME/github/dotfiles/vim/bundle/vim-hybrid-material/base16-material/base16-material.dark.sh"
[[ -s $BASE16_SHELL ]] && source $BASE16_SHELL
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

# for dir in The\ Simpsons\ S[1\2]*
# do
# echo $dir
# cd $dir
# for i in *.mkv
# do
# echo $i
# ffmpeg -i "$i" -map 0 -c copy -c:v libx264 "$i.mkv"
# done
# cd ..
# done

# Open Chrome with CORS disabled
# open -a /Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --args --disable-web-security --user-data-dir

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

export PATH="$PATH:$HOME/.config/yarn/global/node_modules/.bin:$HOME/elasticsearch-2.4.1/bin"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"
# eval "$(newt --completion-script-zsh)"
