{% set user=pillar['user'] %}

/home/{{user}}/.ssh:
  file.directory:
    - user: {{user}}
    - group: root
    - mode: 660

