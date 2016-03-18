base:
  '*':
    - base
    - sudo
    - users.main
    {% if grains['virtual'] == 'oracle' %}
    - virtualbox-guest
    {% endif %}
    - xorg
    - i3wm
    - services
    