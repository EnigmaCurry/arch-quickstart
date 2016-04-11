{% set user=pillar['user'] %}

user_apps:
  pkg:
    - latest
    - names:
      - stow

{% if salt['pillar.get']('salt_deploy_ssh:id_rsa', None) %}
/root/.ssh/salt_deploy_rsa:
  file.managed:
    - user: root
    - group: root
    - mode: 600
    - contents_pillar: salt_deploy_ssh:id_rsa
{% endif %}

Clone dotfiles repositories:
  git.latest:
    - name: {{salt['pillar.get']('dotfile_repos:dotfiles_public:remote', 'https://github.com/EnigmaCurry/dotfiles.git')}}
    - user: root
    - target: /home/{{user}}/dotfiles
    {% if salt['pillar.get']('salt_deploy_ssh:id_rsa', None) %}
    - identity: /root/.ssh/salt_deploy_rsa
    {% endif %}

  file.directory:
    - name: /home/{{user}}/dotfiles
    - user: {{user}}
    - group: {{user}}
    - mode: 755
    - recurse:
      - user
      - group

Stow dotfiles:
  cmd.run:
    - name: stow -v -t /home/{{user}} *
    - cwd: /home/{{user}}/dotfiles


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
    - user: root
    - target: /home/{{user}}/dotfiles-private
    - identity: /root/.ssh/salt_deploy_rsa

  file.directory:
    - name: /home/{{user}}/dotfiles-private
    - user: {{user}}
    - group: {{user}}
    - dir_mode: 700
    - file_mode: 600
    - recurse:
      - user
      - group
      - mode

Stow private dotfiles:
  cmd.run:
    - name: stow -v -t /home/{{user}} *
    - cwd: /home/{{user}}/dotfiles-private

{% endif %}
