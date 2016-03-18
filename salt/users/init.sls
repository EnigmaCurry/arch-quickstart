{% for group, gid in pillar.get('groups', {}).items() %}
{{group}}-group:
  group.present:
    - gid: {{gid}}
{% endfor %}


{% for name, user in pillar.get('users', {}).items() %}
{{name}}-user:
  user.present:
    - uid: {{user.uid}}
    - gid: {{user.gid}}
    - groups:
    {% for group in user.groups %}
      - {{group}}
    {% endfor %}
{% endfor %}


