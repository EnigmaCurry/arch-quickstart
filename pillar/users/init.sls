## This file is overwritten by base_install.sh with the username chosen there.
## This default file is only here if you want to use the saltstack by itself.

groups:
  ryan: 1000

users:
  ryan:
   uid: 1000
   gid: 1000
   groups:
     - wheel

