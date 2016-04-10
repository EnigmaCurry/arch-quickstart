{% if grains['virtual'] == 'oracle' or environ.get('VIRTUAL',None) == 'oracle' %}
virtualbox-guest:
  pkg:
    - latest
    - names:
      - virtualbox-guest-dkms
      - virtualbox-guest-utils
{% endif %}
