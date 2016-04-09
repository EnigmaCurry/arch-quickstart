{% set user=pillar['user'] %}

/home/{{user}}/.ssh:
  file.directory:
    - user: {{user}}
    - group: {{user}}
    - mode: 700

/root/.ssh:
  file.directory:
    - user: root
    - group: root
    - mode: 700

