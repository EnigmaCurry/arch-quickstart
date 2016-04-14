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

# Enable pulseaudio service for user:
/home/{{user}}/.config/systemd/user/default.target.wants/pulseaudio.service:
  file.symlink:
    - target: /usr/lib/systemd/user/pulseaudio.service
    - makedirs: True
/home/{{user}}/.config/systemd/user/sockets.target.wants/pulseaudio.socket:
  file.symlink:
    - target: /usr/lib/systemd/user/pulseaudio.socket
    - makedirs: True
