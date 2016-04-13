BASEDIR=$(dirname "$0")
# Run dotfiles state first, as the user may have states and pillar data defined there:
salt-call -c $BASEDIR/salt/config --local state.apply dotfiles 2>&1 | tee ~/install.log
# Now run the entire highstate:
salt-call -c $BASEDIR/salt/config --local state.highstate 2>&1 | tee -a ~/install.log

