{% set user=pillar['user'] %}

{% if salt['pillar.get']('salt_deploy_ssh:id_rsa', None) %}
/home/{{user}}/.ssh/salt_deploy_rsa:
  file.managed:
    - user: {{user}}
    - group: root
    - mode: 660
    - contents_pillar: salt_deploy_ssh:id_rsa
{% endif %}

Clone dotfiles repositories:
  git.latest:
    - name: {{salt['pillar.get']('dotfile_repos:dotfiles_public:remote', 'https://github.com/EnigmaCurry/dotfiles.git')}}
    - user: {{user}}
    - target: /home/{{user}}/dotfiles
    {% if salt['pillar.get']('salt_deploy_ssh:id_rsa', None) %}
    - identity: /home/{{user}}/.ssh/salt_deploy_rsa
    {% endif %}

{% if salt['pillar.get']('dotfile_repos:dotfiles_private:remote', None) %}
dotfiles_private_known_hosts:
  ssh_known_hosts:
    - name: {{salt['pillar.get']('dotfile_repos:dotfiles_private:known_host:host')}}
    - port: {{salt['pillar.get']('dotfile_repos:dotfiles_private:known_host:port')}}
    - hash_known_hosts: False
    - present
    - key: {{salt['pillar.get']('dotfile_repos:dotfiles_private:known_host:key')}}
    - enc: {{salt['pillar.get']('dotfile_repos:dotfiles_private:known_host:enc')}}
Clone private dotfiles repositories:
  git.latest:
    - name: {{salt['pillar.get']('dotfile_repos:dotfiles_private:remote')}}
    - user: {{user}}
    - target: /home/{{user}}/dotfiles-private
    - identity: /home/{{user}}/.ssh/salt_deploy_rsa
{% endif %}

user_apps:
  pkg:
    - latest
    - names:
      - stow

