{% set user=pillar['user'] %}

include:
  - core
  - users

Apps for dotfiles management:
  pkg:
    - latest
    - names:
      - stow

Ensure non-symlinked config directory exists before stowing anything:
  file.directory:
    - name: /home/{{user}}/.config
    - user: {{user}}
    - group: {{user}}
    - mode: 750
    - require:
      - sls: core
      - sls: users

# Create pulseaudio config directory before dotfiles state creates a symlink there:
/home/{{user}}/.config/pulse:
  file.directory:
    - user: {{user}}
    - group: {{user}}
    - mode: 700

/root/.ssh:
  file.directory:
    - user: root
    - group: root
    - mode: 700

{% if salt['pillar.get']('salt_deploy_ssh:id_rsa', None) %}
Copy the SSH key from pillar to the root account:
  file.managed:
    - name: /root/.ssh/salt_deploy_rsa
    - user: root
    - group: root
    - mode: 600
    - contents_pillar: salt_deploy_ssh:id_rsa

Configure ssh to use deploy key:
  file.managed:
    - name: /root/.ssh/config
    - user: root
    - group: root
    - mode: 600
    - contents: |
        Host *
            IdentityFile ~/.ssh/salt_deploy_rsa
{% endif %}

Create directory to hold user's git checkouts:
  file.directory:
    - name: /home/{{user}}/git
    - user: {{user}}
    - group: {{user}}
    - mode: 750
    
Clone dotfiles repositories:
  git.latest:
    - name: {{salt['pillar.get']('dotfile_repos:dotfiles_public:remote', 'https://github.com/EnigmaCurry/dotfiles.git')}}
    - user: root
    - target: /home/{{user}}/git/dotfiles
    {% if salt['pillar.get']('salt_deploy_ssh:id_rsa', None) %}
    - identity: /root/.ssh/salt_deploy_rsa
    {% endif %}

  file.directory:
    - name: /home/{{user}}/git/dotfiles
    - user: {{user}}
    - group: {{user}}
    - mode: 755
    - recurse:
      - user
      - group

Remove stock bashrc:
  cmd.run:
    - name: rm /home/{{user}}/.bashrc

Stow dotfiles:
  cmd.run:
    # Stow any dir that starts with alphanum, ignores ones starting with _
    - name: stow -v -t /home/{{user}} [a-zA-Z0-9]*
    - cwd: /home/{{user}}/git/dotfiles


{% if salt['pillar.get']('dotfile_repos:dotfiles_private:remote', None) %}
Copy private dofiles SSH Host key into known_hosts:
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
    - target: /home/{{user}}/git/dotfiles-private
    - identity: /root/.ssh/salt_deploy_rsa

  file.directory:
    - name: /home/{{user}}/git/dotfiles-private
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
    # Stow any dir that starts with alphanum, ignores ones starting with _
    - name: stow -v -t /home/{{user}} [a-zA-Z0-9]*
    - cwd: /home/{{user}}/git/dotfiles-private

{% endif %}
