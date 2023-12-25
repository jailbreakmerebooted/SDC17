export PATH="/usr/local/sbin:/var/jb/usr/local/sbin:/usr/local/bin:/var/jb/usr/local/bin:/usr/sbin:/var/jb/usr/sbin:/usr/bin:/var/jb/usr/bin:/sbin:/var/jb/sbin:/bin:/var/jb/bin:/usr/bin/X11:/var/jb/usr/bin/X11:/usr/games:/var/jb/usr/games"
export TMPDIR="/var/jb/tmp"
export HOME="/var/jb/home"
export EDITOR="/var/jb/usr/bin/editor"
export PAGER="/var/jb/usr/bin/pager"
username=$(whoami)
export LOGNAME=$username
export USER=$username
sparkd&
disown
exit
