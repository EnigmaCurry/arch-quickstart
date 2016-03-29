### ###################################################################
### Pillar data.

### For those of you not familiar with saltstack, this is the data
### that is considered private and custom to your particular
### environment. This is where you can define your user accounts as
### well as the place to pull your dot files from.

### NOTE: If you are using base_install.sh to bootstrap your install,
### you should be passing this information in via the PILLAR_DATA
### environment variable, not by editing this file directly. This
### default file will be overwritten by base_install.sh
### ###################################################################

### ###################################################################
### Users and groups:
### ###################################################################

# Users to create:
users:
  ryan:
   uid: 1000
   gid: 1000
   groups:
     - wheel

# Groups to create:
groups:
  ryan: 1000

# The main user account of the system:
user: ryan

### ###################################################################
### Dotfile repository and credentials:

### Your dotfiles are assumed to be contained in one or two git
### repositories, dotfiles_public, and optionally dotfiles_private.
### If you wish to pull in private dotfiles from a non-public git
### repository, you need to specify all of the connection details
### here, including the git remote, it's SSH connection known_host
### details, and the private SSH key to access the server. This key
### needs to be non-password protected so that it can be used by the
### script non-interactively.
### ###################################################################

dotfile_repos:
  dotfiles_public:
    remote: https://github.com/EnigmaCurry/dotfiles.git
#  dotfiles_private:
#    remote: ssh://git@your_server.example.com:22/dotfiles-private.git
#    known_host: 
#      host: your_server.example.com
#      port: 22
#      key: AAAAE2Vxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx=
#      enc: ecdsa-sha2-nistp256

#salt_deploy_ssh:
#  id_rsa : |
#    -----BEGIN RSA PRIVATE KEY-----
#    Your deployment key here
#    -----END RSA PRIVATE KEY-----

