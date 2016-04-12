/etc/sudoers.d:
  file:
    - directory
    - clean: True
    - require:
      - file: /etc/sudoers.d/10-wheel-group

/etc/sudoers.d/10-wheel-group:
  file:
    - managed
    - content: |
        %wheel ALL=(ALL) ALL
