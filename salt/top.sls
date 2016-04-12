base:
  '*':
    - base
    - sudo
    - users
    - network
    - virtualbox-guest
    - xorg
    - i3wm
    - dotfiles
    {% for state in salt['pillar.get']('user_states'): %}
    - {{state}}
    {% endfor %}
