# arch-quickstart

This is not *The Arch Way* of installing Arch Linux, but it's my way.

What is here is still pretty custom fit for my needs, but I hope to continue to work on this to make it more generically reusable for other people.

## Install

 * Boot the computer you will install to with the [Arch Linux installation media](https://www.archlinux.org/download/)
 * Make sure the network comes up. If you're wired, it should come up via DHCP automatically. If you're using wifi, run wifi-menu to get online.
 * Run the following commands to install:
 
        # Download the script:
        curl https://git.io/va6Ei -o base_install.sh 

        # Open up base_install.sh in nano/vi and edit the install parameters near the top of the file.
        
        # Run the script:
        bash base_install.sh
        
        # You'll be prompted for a username and password for your new user account
        # After that, sit back and let it run. Reboot the computer when done.
        
 * Or, do it all in one line. You can specify any of the parameters in the shell environment:
 
        curl https://git.io/va6Ei | INSTALL_DEVICE=/dev/vda USER_NAME=ryan USER_PASSWD=pass HOSTNAME=lappy bash
