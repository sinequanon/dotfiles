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

export PATH=$PATH:$HOME/bin:/usr/local/bin
# export MANPATH="/usr/local/man:$MANPATH"

source $ZSH/oh-my-zsh.sh

GRUVBOX_SHELL="$HOME/github/dotfiles/vim/bundle/gruvbox/gruvbox_256pallette_osx.sh"
[[ -s $GRUVBOX_SHELL ]] && source $GRUVBOX_SHELL

# You may need to manually set your language environment
export LANG=en_US.UTF-8

if [[ `uname` == 'Darwin' ]]; then
  alias ctags='`brew --prefix`/bin/ctags'
  . `brew --prefix`/etc/profile.d/z.sh
  export EDITOR='/usr/local/bin/vim'
elif [[ `uname` == 'Linux' ]]; then
  # Start Z https://github.com/rupa/z
  export EDITOR='/usr/bin/vim'
  . ~/z.sh
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

# alias jshakti="pkill gulp; gulp js && shakti"
# alias ashakti="pkill gulp; gulp assets && shakti"
# alias cshakti="pkill gulp; gulp clearCache && gulp clean && gulp locales && gulp assets && shakti"

# alias easyget="curl -b ~/Dropbox/easynews.cookies.txt -v -L -O $1"
# alias easyreget="curl -b ~/Dropbox/easynews.cookies.txt -C - -v -L -O $1"

alias rm="trash"

#Postgres Aliases
alias palpha='psql --host=prequel-dev.curho7ugte77.us-west-2.rds.amazonaws.com --username=prequel_dev prequel_alpha'
alias pbeta='psql --host=prequelbeta.cjrtfdmnhffu.us-west-2.rds.amazonaws.com --username=prequel_dev prequel_dev'
alias pprod='psql --host=prequel-prod.cjrtfdmnhffu.us-west-2.rds.amazonaws.com --username=prequel prequel_prod'
# alias plocal='psql --host=127.0.0.1 --username=postgres cia-prequel-api_development'
alias pdev='psql --host=prequel-dev.chahntavgquc.us-west-2.rds.amazonaws.com --username=prequel_dev prequel_dev'

alias ssh='TERM=xterm-256color ssh'

alias apiWslStart='sudo service postgresql start && sudo service elasticsearch start && sudo mkdir -p /run/metatron/decrypted && sudo touch /run/metatron/decrypted/sentry_raven_dsn_test.txt && rails s'

alias m3uget='ffmpeg -i https://url.com/videos/hls/e4/19/d4/e419d439729e1daf694979e0ed646869/hls-360p.m3u8\?e\=1531382653\&l\=0\&h\=37cb6081b2a2033f35d32e768dad1c76 -c copy -bsf:a aac_adtstoasc output1.mp4'
# Find lines of code
loc() { find . -type f \( -name '*.js' -o -name '*.css' \) -not -path '.*node_modules*' | xargs wc -l }

nftotals() {
  # set -x
  unset var
  unset payload
  unset nextPageToken
  unset data
  pandoraURL="https://api.pandora.prod.netflix.net:7004/REST/v1/users/netflix.com/?size=500"
  payload=$(metatron curl -a pandora $pandoraURL | jq ".")
  nextPageToken=$(jq -r ".nextPageToken" <<< $payload)
  # data=$(jq -r ".data[].addresses[]?.city" <<< $payload)
  data=$(jq -r ".data[].customAttributes.location" <<< $payload)

  echo "=== Total for this pass ==="
  cat <<< "$data" | sort | uniq -c | sort -rn
  var="$var $data"
  runningTotal=$(cat <<< "$var" | sort | uniq -c | sort -rn)
  echo "========= Running Total ========="
  cat <<< "$runningTotal"
  until [[ $nextPageToken == "null" ]]; do
    payload=$(metatron curl -a pandora "$pandoraURL&nextPageToken=$nextPageToken" | jq ".")
    nextPageToken=$(jq -r ".nextPageToken" <<< $payload)
    # data=$(jq -r ".data[].addresses[]?.city" <<< $payload)
    data=$(jq -r ".data[].customAttributes.location" <<< $payload)
    # If data exists
    if  [ -n "${data// }" ]; then
      var="$var $data"
      echo "=== Total for this pass ==="
      cat <<< "$data" | sort | uniq -c | sort -rn
      runningTotal=$(cat <<< "$var" | sort | uniq -c | sort -rn)
      echo "========= Running Total ========="
      cat <<< "$runningTotal"
      total=$(cat <<< "$runningTotal" | awk '{sum+=$1} END{ print sum}')
      cat <<< $total
    fi
  done
}

nftitles() {
  # set -x
  unset var
  unset payload
  unset nextPageToken
  unset data
  pandoraURL="https://api.pandora.prod.netflix.net:7004/REST/v1/users/netflix.com/?size=500"
  payload=$(metatron curl -a pandora $pandoraURL | jq ".")
  nextPageToken=$(jq -r ".nextPageToken" <<< $payload)
  data=$(jq -r ".data[].customAttributes.jobLevelDescription" <<< $payload)

  echo "=== Total for this pass ==="
  cat <<< "$data" | sort | uniq -c | sort -rn
  var="$var $data"
  runningTotal=$(cat <<< "$var" | sort | uniq -c | sort -rn)
  echo "========= Running Total ========="
  cat <<< "$runningTotal"
  until [[ $nextPageToken == "null" ]]; do
    payload=$(metatron curl -a pandora "$pandoraURL&nextPageToken=$nextPageToken" | jq ".")
    nextPageToken=$(jq -r ".nextPageToken" <<< $payload)
    data=$(jq -r ".data[].customAttributes.jobLevelDescription" <<< $payload)
    # If data exists
    if  [ -n "${data// }" ]; then
      var="$var $data"
      echo "=== Total for this pass ==="
      cat <<< "$data" | sort | uniq -c | sort -rn
      runningTotal=$(cat <<< "$var" | sort | uniq -c | sort -rn)
      echo "========= Running Total ========="
      cat <<< "$runningTotal"
      total=$(cat <<< "$runningTotal" | awk '{sum+=$1} END{ print sum}')
      cat <<< $total
    fi
  done
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
export NODE_ENV=development

if [[ $WSL == true ]]; then
 # BASE16_SHELL="$HOME/github/base16-shell/scripts/base16-material-palenight.sh"
 # [[ -s $BASE16_SHELL ]] && source $BASE16_SHELL
else
  # Set hybrid-material colors
  # BASE16_SHELL="$HOME/github/dotfiles/vim/bundle/vim-hybrid-material/base16-material/base16-material.dark.sh"
  # [[ -s $BASE16_SHELL ]] && source $BASE16_SHELL
fi
#########################

# IPAD4WHITE_ESN='NFAPPL-D1-IPAD3=4-5E466F974D24EA3853A21720C67D64D3DA772EE7C991A01E2F4853FCC732BBEB'
# FIT_SERVER_TEST='fit.us-west-2.dyntest.netflix.net:7101'
# FIT_SERVER_PROD='fit.netflix.net:7101'
# END_SUBSCRIBER_SESSION='v1/sessions/end'
# BEGIN_SUBSCRIBER_SESSION='v1/sessions/new/s/subscriber'
# subscriber-fail-test () {
#     [ $# -eq 0 ] && FOO="esn=$IPAD4WHITE_ESN" || FOO="cid=$1"
#     echo "$FIT_SERVER_TEST/$BEGIN_SUBSCRIBER_SESSION?$FOO"
#     curl -i -X POST "$FIT_SERVER_TEST/$BEGIN_SUBSCRIBER_SESSION?$FOO"
# }
# subscriber-restore-test () {
#     [ $# -eq 0 ] && FOO="esn=$IPAD4WHITE_ESN" || FOO="cid=$1"
#     echo "$FIT_SERVER_TEST/$END_SUBSCRIBER_SESSION?$FOO"
#     curl -i -X POST "$FIT_SERVER_TEST/$END_SUBSCRIBER_SESSION?$FOO"
# }
# subscriber-fail-prod () {
#     [ $# -eq 0 ] && FOO="esn=$IPAD4WHITE_ESN" || FOO="cid=$1"
#     echo "$FIT_SERVER_PROD/$BEGIN_SUBSCRIBER_SESSION?$FOO"
#     curl -i -X POST "$FIT_SERVER_PROD/$BEGIN_SUBSCRIBER_SESSION?$FOO"
# }
# subscriber-restore-prod () {
#     [ $# -eq 0 ] && FOO="esn=$IPAD4WHITE_ESN" || FOO="cid=$1"
#     echo "$FIT_SERVER_PROD/$END_SUBSCRIBER_SESSION?$FOO"
#     curl -i -X POST "$FIT_SERVER_PROD/$END_SUBSCRIBER_SESSION?$FOO"
# }

# compilejstags () {
#     for f ($1/(^node_modules/)#*.js*) { jsctags $f -f >> ./tags }
# }

# kubrickjstags () {
#     for f (/Users/rowell/stash/kubrick/device/(^node_modules/)#*.js*) { jsctags $f -f >> ./tags }
# }

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

export PATH="$PATH:$HOME/.config/yarn/global/node_modules/.bin"
export N_PREFIX="$HOME/n"; [[ :$PATH: == *":$N_PREFIX/bin:"* ]] || PATH+=":$N_PREFIX/bin"  # Added by n-install (see http://git.io/n-install-repo).
export PREQUEL_DEV_MEECHAM_MOCK_EMAIL="rsotto@netflix.com"

if [[ $WSL == true ]]; then
  # Prevent zsh in WSL from complaining
  # https://github.com/wting/autojump/issues/474#issuecomment-294300096
  # unsetopt BG_NICE
  # export DISPLAY=:0
  # export LIBGL_ALWAYS_INDIRECT=1

  # Scale XAPPs in conjunction with native windows for WSL
  export GDK_DPI_SCALE=1
  #Change ls colours
  # LS_COLORS="ow=01;36;40" && export LS_COLORS
  # eval "$(dircolors ~/.gruvbox.dircolors)"

  #make cd use the ls colours
  # zstyle ':completion:*' list-colors "${(@s.:.)LS_COLORS}"
  autoload -Uz compinit
  compinit
fi

BROWSER="w3m"

ulimit -n 65536 65536

export PATH="/usr/local/opt/python@2/libexec/bin:$PATH"
export PATH="/usr/local/opt/python@2/bin:$PATH"

# Add RVM to PATH for scripting. Make sure this is the last PATH variable change.
export PATH="$PATH:$HOME/.rvm/bin"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"
