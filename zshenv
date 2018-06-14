if grep -qE "(Microsoft|WS)" /proc/version &> /dev/null ; then
  WSL=true
else
  WSL=false
fi

if [[ $WSL == true ]]; then
  # Prevent zsh in WSL from complaining
  # https://github.com/wting/autojump/issues/474#issuecomment-294300096
  unsetopt BG_NICE
  export DISPLAY=:0
  export LIBGL_ALWAYS_INDIRECT=1
fi
