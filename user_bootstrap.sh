BASEDIR=$(dirname "$0")
salt-call -c $BASEDIR/salt/config --local --file-root=$BASEDIR/salt --pillar-root=$BASEDIR/pillar state.highstate
