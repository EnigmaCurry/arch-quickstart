# arch-quickstart

This is not *The Arch Way* of installing Arch Linux, but it's my way.

What is here is still pretty custom fit for my needs, but I hope to continue to work on this to make it more generically reusable for other people.

## Install

 * Boot the computer you will install to with the [Arch Linux installation media](https://www.archlinux.org/download/)
 * Make sure the network comes up. If you're wired, it should come up via DHCP automatically. If you're using wifi, run wifi-menu to get online.
 * Run the following command to install, specifying the most common options:

        INSTALL_DEVICE=/dev/vda USER=ryan PASS=pass HOSTNAME=lappy bash <(curl -L https://git.io/va6Ei)

 * Alternatively, you can take a bit more care and download the script, edit the script in nano,vim and edit the options near the top of the script:

        curl -L https://git.io/va6Ei -o base_install.sh 

        nano base_install.sh
        
        bash base_install.sh
        
## Development

### Create Arch testbed VM

This script was developed with the aid of VirtualBox. Using it's snapshot feature makes it easy to test this script over and over from a fresh state.

Create VM:
 * Call it 'arch-testbed'
 * Turn on the serial port, use a 'host pipe' and uncheck 'Connect to existing', choose a path like /tmp/vbox_tty.
 * Boot up the machine headless
 * Conenct with: minicom -D unix#/tmp/vbox_tty
 * On grub screen press tab over the boot entry line add these boot parameters: console=ttyS0,38400, then press Enter to boot it up
 * Boot should continue all the way to the login screen (if not, there's a problem with the serial port settings)
 * Once you get to the terminal, save a snapshot of the VM, call it "initial".
 * Reset to the initial state whenever you want:
 
        VBoxManage controlvm "arch-testbed" poweroff ; VBoxManage snapshot "arch-testbed" restore "initial" && VBoxManage startvm "arch-testbed" --type headless 
		
 * The serial port connection is super fast on VM reset, and is much more productive than the SSH instructions that existed here before.
