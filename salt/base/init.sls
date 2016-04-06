# Things that aren't installed by pacstrap that I still consider to be part of the base install:
base:
  pkg:
    - latest
    - names:
      - linux-headers
      - openssh

/etc/systemd/system/multi-user.target.wants/sshd.service:
  file.symlink:
    - target: /usr/lib/systemd/system/sshd.service
