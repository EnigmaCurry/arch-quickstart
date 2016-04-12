Networking tools:
  pkg:
    - latest
    - names:
      - wpa_supplicant
  service.enabled:
    - names:
      - systemd-networkd
#      - systemd-resolved
      
# /etc/resolv.conf:
#   file.symlink:
#     - target: /run/systemd/resolve/resolv.conf
#     - force: True

/etc/wpa_supplicant.conf:
  file.managed:
    - mode: 600

{% for interface in salt['pillar.get']('network_interfaces'): %}

{% endfor %}