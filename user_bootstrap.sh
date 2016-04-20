set -e
BASEDIR=$(dirname "$0")
[ -z "$LOG" ] && LOG=/dev/null

exe() { echo "\$ $@" ; "$@" ; }

echo "# Applying highstate"
exe salt-call -c $BASEDIR/salt/config --local state.highstate 2>&1 | tee -a $LOG


