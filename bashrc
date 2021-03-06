# Prevent SCP from sourcing this .bashrc
[ -z "$PS1"  ] && return

alias sb='source ~/.bashrc'
alias vb='vi ~/.bashrc'
alias vi='vim'
alias vim='mvim -v'

source ~/.server

if [ -f `brew --prefix`/etc/bash_completion ]; then
    . `brew --prefix`/etc/bash_completion
fi

PS1='\[\033[31m\]`__git_ps1`\[\033[00m\] \[\033[34m\]\w\n[\[\033[32m\]\u@\h\[\033[00m\]] \$ '

LS_COLORS="no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ex=01;32:*.tar=01;31:*.tgz=01;31:*.svgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:"

set -o vi

# Activate the autocd option. It will let you type .. for cd .. and will actually let you use any directory as a command name and will cd to it:
shopt -s autocd
shopt -s cdable_vars
shopt -s cdspell

export P4CONFIG=~/.p4config
export P4HOST=$P4_HOST
export P4CLIENT=$P4_CLIENT
export P4_HOME=/Users/$USERNAME/$WORKSPACE
export GIT_P4_HOME=/Users/$USERNAME/p4-git-mobileui
export PATH=/Users/$USERNAME/bin:/usr/local/bin:/usr/local/share/npm/bin:/Users/$USERNAME/Applications:/Users/$USERNAME/dev/api-sdk/bin:/Developer/usr/bin::$PATH
export EDITOR="vim"
export CDPATH=.:$HOME/stash:$HOME/

alias p4='p4 -d `pwd`'
alias ls='ls -FG'
alias la='ls -FGa'
alias ll='ls -FGl'
alias lla='ls -FGla'
alias tmux='TERM=screen-256color-bce tmux'
alias nflog="deviceconsole  | ack -i UI_SCRIPT | ack -v 'SCROLLER' | cut -d ' ' -f10-40 | spc -c ~/Dropbox/spcrc-nfapplog"
alias easyget="curl -b ~/Dropbox/easynews.cookies.txt -v -L -O $1"
alias easyreget="curl -b ~/Dropbox/easynews.cookies.txt -C - -v -L -O $1"

alias co="git checkout"
alias st="git status"
alias br="git branch"

source /Users/rowell/Dropbox/dev/base16-shell/base16-railscasts.dark.sh

# Start Z https://github.com/rupa/z
. `brew --prefix`/etc/profile.d/z.sh

# Open man page in preview
pman () {
    #man -t $* | ps2pdf - - | open -g -f -a /Applications/Preview.app
    #man -t "${1}" | open -f -a /Applications/Preview.app
    man -t $@ | open -f -a /Applications/Preview.app
}

#open man page in textmate
tman () {
  MANWIDTH=160 MANPAGER='col -bx' man $@ | mate
}
cs() { cd $1; ls; }

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

