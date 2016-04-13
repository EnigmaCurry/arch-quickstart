BASEDIR=$(dirname "$0")
salt-call -c $BASEDIR/salt/config --local state.highstate 2>&1 | tee ~/install.log

