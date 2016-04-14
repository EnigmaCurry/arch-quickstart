{% set user=pillar['user'] %}

Sound apps:
  pkg:
    - latest
    - names:
      - avahi
      - alsa-utils
      - alsa-plugins
      - pulseaudio
      - pulseaudio-alsa
      - pulseaudio-zeroconf
      - paprefs
      - pavucontrol
      - rygel
  service.enabled:
    - names:
      - avahi-daemon

Enable pulseaudio for user:
  cmd.run:
    - name: systemctl --user enable pulseaudio
