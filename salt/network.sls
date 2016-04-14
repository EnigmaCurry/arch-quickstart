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
    - source: salt://wpa_supplicant.conf

{% for interface in salt['pillar.get']('auto_wifi'): %}
/etc/systemd/network/{{interface}}.network:
  file.managed:
    - contents: |
        [Match]
        Name={{interface}}
        [Network]
        DHCP=yes
/etc/wpa_supplicant/wpa_supplicant-{{interface}}.conf:
  file.symlink:
    - target: /etc/wpa_supplicant.conf
Automatically enable wifi:
  service.enabled:
    - names:
      - wpa_supplicant@{{interface}}.service
{% endfor %}
