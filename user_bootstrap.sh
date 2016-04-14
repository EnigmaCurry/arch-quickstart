set -e
BASEDIR=$(dirname "$0")
[ -z "$LOG" ] && LOG=/dev/null

exe() { echo "\$ $@" ; "$@" ; }

# Run dotfiles state first, as the user may have states and pillar data defined there:
echo "# Applying dotfile state"
exe salt-call -c $BASEDIR/salt/config --local state.apply dotfiles 2>&1 | tee $LOG

echo "# Applying highstate"
exe salt-call -c $BASEDIR/salt/config --local state.highstate 2>&1 | tee -a $LOG


