set -e
BASEDIR=$(dirname "$0")
[ -z "$LOG" ] && LOG=/dev/null
# Run dotfiles state first, as the user may have states and pillar data defined there:
salt-call -c $BASEDIR/salt/config --local state.apply dotfiles 2>&1 | tee $LOG
# Now run the entire highstate:
salt-call -c $BASEDIR/salt/config --local state.highstate 2>&1 | tee -a $LOG


