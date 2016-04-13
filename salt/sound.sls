{% set user=pillar['user'] %}

Sound apps:
  pkg:
    - latest
    - names:
      - alsa-utils
      - alsa-plugins
      - pulseaudio
      - pulseaudio-alsa
      - pulseaudio-zeroconf
      - paprefs
      - pavucontrol
      - rygel
