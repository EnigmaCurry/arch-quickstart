# arch-quickstart

This is not *The Arch Way* of installing Arch Linux, but it's my way.

What is here is still pretty custom fit for my needs, but I hope to continue to work on this to make it more generically reusable for other people.

## Install

 * Boot the computer you will install to with the [Arch Linux installation media](https://www.archlinux.org/download/)
 * Make sure the network comes up. If you're wired, it should come up via DHCP automatically. If you're using wifi, run wifi-menu to get online.
 * Run the following command to install:
 
        curl https://raw.githubusercontent.com/EnigmaCurry/arch-quickstart/master/base_install.sh > base_install.sh && bash base_install.sh
