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

{% if salt['pillar.get']('wpa_supplicant') %}
/etc/wpa_supplicant.conf:
  file.managed:
    - mode: 600
    - contents_pillar: wpa_supplicant
{% endif %}

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
