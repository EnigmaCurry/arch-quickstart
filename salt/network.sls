Networking tools:
  pkg:
    - latest
    - names:
      - wpa_supplicant
  service.enabled:
    - names:
      - systemd-networkd
      - systemd-resolved
      
/etc/resolv.conf:
  file.symlink:
    - target: /run/systemd/resolve/resolv.conf
    - force: True

