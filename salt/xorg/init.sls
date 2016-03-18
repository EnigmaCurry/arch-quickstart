Xorg:
  pkg:
    - latest
    - names:
      - xorg-server
      - xorg-server-utils
      - xorg-xinit
      - xorg-xrdb
      - xorg-xkill
      - xorg-xwininfo
      - arandr
      - xdotool
      - lightdm
      - lightdm-gtk-greeter
      {% for gpu in grains['gpus'] %}
        {% if gpu['vendor'] == 'nvidia' %}
      - xf86-video-nouveau
        {% endif %}
      {% endfor %}
    - require:
      - cmd: xorg-apps

## Workaround for xorg-apps meta-package
## Salt doesn't like Arch based meta packages :(
## See https://github.com/saltstack/salt/issues/15749 
## I think this means that Salt can't uninstall these?
xorg-apps:
  cmd:
    - run
    - name: pacman -S --needed --noconfirm xorg-apps



