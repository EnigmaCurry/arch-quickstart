{% set user=pillar['user'] %}

/home/{{user}}/.ssh:
  file.directory:
    - user: {{user}}
    - group: {{user}}
    - mode: 600

