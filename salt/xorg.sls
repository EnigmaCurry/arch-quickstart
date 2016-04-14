Xorg:
  pkg:
    - latest
    - names:
      - xorg-server
      - xorg-server-utils
      - xorg-xinit
      - arandr
      - xdotool
      - lightdm
      - lightdm-gtk-greeter
      {% for gpu in grains['gpus'] %}
        {% if gpu['vendor'] == 'nvidia' %}
      - xf86-video-nouveau
        {% endif %}
        {% if gpu['vendor'] == 'intel' %}
      - xf86-video-intel
        {% endif %}
      {% endfor %}
      ## Salt doesn't like Arch based meta packages like xorg-apps :(
      ## See https://github.com/saltstack/salt/issues/15749 
      ## So we'll just list all of xorg-apps here as a workaround:
      - xorg-bdftopcf
      - xorg-iceauth
      - xorg-luit
      - xorg-mkfontdir
      - xorg-mkfontscale
      - xorg-sessreg
      - xorg-setxkbmap
      - xorg-smproxy
      - xorg-x11perf
      - xorg-xauth
      - xorg-xbacklight
      - xorg-xcmsdb
      - xorg-xcursorgen
      - xorg-xdpyinfo
      - xorg-xdriinfo
      - xorg-xev
      - xorg-xgamma
      - xorg-xhost
      - xorg-xinput
      - xorg-xkbcomp
      - xorg-xkbevd
      - xorg-xkbutils
      - xorg-xkill
      - xorg-xlsatoms
      - xorg-xlsclients
      - xorg-xmodmap
      - xorg-xpr
      - xorg-xprop
      - xorg-xrandr
      - xorg-xrdb
      - xorg-xrefresh
      - xorg-xset
      - xorg-xsetroot
      - xorg-xvinfo
      - xorg-xwd
      - xorg-xwininfo
      - xorg-xwud
  service.enabled:
    - names:
      - lightdm


Turn caps-lock into a super key:
  file.managed:
    - name: /etc/X11/xorg.conf.d/90-custom-kbd.conf
    - contents: |
          Section "InputClass"
              Identifier "keyboard defaults"
              MatchIsKeyboard "on"
              Option "XKbOptions" "caps:super"
          EndSection

{% if salt['pillar.get']('xorg:primary_display', None) %}
Monitor configuration:
  file.managed:
    - name: /etc/X11/xorg.conf.d/10-monitor.conf
    - contents: |
        Section "Monitor"
            Identifier "{{pillar['xorg']['primary_display']}}"
            Option     "Primary" "true"
        EndSection
{% endif %}
