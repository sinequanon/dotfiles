alias sourcebash='source ~/.bashrc'
alias vibash='vi ~/.bashrc'
alias vi='vim'
alias vim='mvim -v'

source ~/.server
if [ -f `brew --prefix`/etc/bash_completion ]; then
    . `brew --prefix`/etc/bash_completion
fi

PS1='\[\033[31m\]`__git_ps1`\[\033[00m\] \[\033[34m\]\w\n[\[\033[32m\]\u@\h\[\033[00m\]] \$ '

LS_COLORS="no=00:fi=00:di=01;34:ln=01;36:pi=40;33:so=01;35:do=01;35:bd=40;33;01:cd=40;33;01:or=40;31;01:su=37;41:sg=30;43:ex=01;32:*.tar=01;31:*.tgz=01;31:*.svgz=01;31:*.arj=01;31:*.taz=01;31:*.lzh=01;31:*.lzma=01;31:*.zip=01;31:*.z=01;31:*.Z=01;31:*.dz=01;31:*.gz=01;31:*.bz2=01;31:*.bz=01;31:*.tbz2=01;31:*.tz=01;31:*.deb=01;31:*.rpm=01;31:*.jar=01;31:*.rar=01;31:*.ace=01;31:*.zoo=01;31:*.cpio=01;31:*.7z=01;31:*.rz=01;31:*.jpg=01;35:*.jpeg=01;35:*.gif=01;35:*.bmp=01;35:*.pbm=01;35:*.pgm=01;35:*.ppm=01;35:*.tga=01;35:*.xbm=01;35:*.xpm=01;35:*.tif=01;35:*.tiff=01;35:*.png=01;35:*.svg=01;35:*.mng=01;35:*.pcx=01;35:*.mov=01;35:*.mpg=01;35:*.mpeg=01;35:*.m2v=01;35:*.mkv=01;35:*.ogm=01;35:*.mp4=01;35:*.m4v=01;35:*.mp4v=01;35:*.vob=01;35:*.qt=01;35:*.nuv=01;35:*.wmv=01;35:*.asf=01;35:*.rm=01;35:*.rmvb=01;35:*.flc=01;35:*.avi=01;35:*.fli=01;35:*.gl=01;35:*.dl=01;35:*.xcf=01;35:*.xwd=01;35:*.yuv=01;35:*.aac=00;36:*.au=00;36:*.flac=00;36:*.mid=00;36:*.midi=00;36:*.mka=00;36:*.mp3=00;36:*.mpc=00;36:*.ogg=00;36:*.ra=00;36:*.wav=00;36:"

set -o vi

#export JDK_16=/System/Library/Frameworks/JavaVM.framework/Versions/1.6/Home
#export JDK_15=/System/Library/Frameworks/JavaVM.framework/Versions/1.5/Home

export GROOVY_HOME=/usr/local/Cellar/groovy/2.0.5/libexec #/Users/$USERNAME/dev/groovy-1.8.5
export API_NEXT_HOST=
export P4CONFIG=~/.p4config
export P4HOST=$P4_HOST
export P4CLIENT=$P4_CLIENT
export P4_HOME=/Users/$USERNAME/$WORKSPACE
export GIT_P4_HOME=/Users/$USERNAME/p4-git-mobileui
#export ANT_HOME=$GIT_P4_HOME/Tools/apache-ant/apache-ant-1.7.1
export JAVA_HOME=$JDK_16
export CATALINA_HOME=$P4_HOME/thirdparty/tomcat/6.0.32
export PATH=/Users/$USERNAME/bin:/usr/local/bin:/usr/local/share/npm/bin:/Users/$USERNAME/Applications:$CATALINA_HOME/bin:$GROOVY_HOME/bin:/Users/$USERNAME/dev/api-sdk/bin:/Developer/usr/bin:/Users/rowell/libimobiledevice-macosx-master:$PATH
export EDITOR="vim"
export CDPATH=.:$HOME/git-mobileui/10FootUI/Apps/HTML/Tablet:$HOME/

alias p4='p4 -d `pwd`'
alias ls='ls -FG'
alias tmux='TERM=screen-256color-bce tmux'
alias nflog="idevicesyslog  | ack -i UI_SCRIPT | ack -v 'SCROLLER' | cut -d ' ' -f3,10-40 | spc -c ~/Dropbox/spcrc-nfapplog"
alias easyget="curl -b ~/Dropbox/easynews.cookies.txt -v -L -O $1"
alias easyreget="curl -b ~/Dropbox/easynews.cookies.txt -C - -v -L -O $1"

alias co="git checkout"
alias st="git status"
alias br="git branch"

source /Users/rowell/Dropbox/dev/base16-shell/base16-railscasts.dark.sh
# Start Z https://github.com/rupa/z

. $HOME/Dropbox/bin/z.sh

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
