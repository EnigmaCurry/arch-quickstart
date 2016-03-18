/etc/sudoers.d:
  file:
    - directory
    - clean: True
    - require:
      - file: /etc/sudoers.d/10-wheel-group

/etc/sudoers.d/10-wheel-group:
  file:
    - managed
    - source: salt://sudo/10-wheel-group
    