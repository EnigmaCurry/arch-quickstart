base:
  '*':
    - base
    - sudo
    - users
    {% if grains['virtual'] == 'oracle' %}
    - virtualbox-guest
    {% endif %}
    - xorg
    - i3wm
    - services
    