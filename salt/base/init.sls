# Things that aren't installed by pacstrap that I still consider to be part of the base install:
base:
  pkg:
    - latest
    - names:
      - linux-headers
      - openssh
  service.enabled:
    - names:
      - sshd
