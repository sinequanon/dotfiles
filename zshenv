if grep -qE "(Microsoft|WS)" /proc/version &> /dev/null ; then
  WSL=true
else
  WSL=false
fi
