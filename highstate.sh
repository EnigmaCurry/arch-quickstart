BASEDIR=$(dirname "$0")
salt-call -c $BASEDIR/salt/config --local state.highstate

