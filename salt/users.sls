# Create all groups defined in pillar:
{% for group, gid in pillar.get('groups', {}).items() %}
{{group}}-group:
  group.present:
    - gid: {{gid}}
    - name: {{group}}
{% endfor %}

# Create all users defined in pillar:
{% for name, user in pillar.get('users', {}).items() %}
{{name}}:
  user.present:
    - name: {{user}}
    - uid: {{user.uid}}
    - gid: {{user.gid}}
    - groups:
    {% for group in user.groups %}
      - {{group}}
    {% endfor %}

{{name}} home dir:
  file.directory:
    - name: /home/{{name}}
    - user: {{name}}
    - group: {{name}}
    - mode: 755
{% endfor %}
