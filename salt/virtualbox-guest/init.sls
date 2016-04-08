{% if grains['virtual'] == 'oracle' %}
virtualbox-guest:
  pkg:
    - latest
    - names:
      - virtualbox-guest-dkms
      - virtualbox-guest-utils
{% endif %}
