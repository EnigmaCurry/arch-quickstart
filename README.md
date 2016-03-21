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

This script was developed with the aid of VirtualBox. I create a VM called "Arch testbed" that is just the Installer CD booted up, with static networking setup and ssh turned on. Taking a snapshot of this state allows me to test arch-quickstart over and over from a clean state. There's [a script in /devtools](https://github.com/EnigmaCurry/arch-quickstart/tree/master/devtools/createvm.sh) that will automatically create this VM for you, but you can just as easily do it by hand. It's a one-time job, once you have the VM and the snapshot saved, you just reuse that over and over in a dev loop:


	    # Do this one time to create the VM:
        ./devtools/createvm.sh
		
	    # Do this as many times as you want to test your arch-quickstart modifications inside the VM.
		# Change the IP address to whatever your VM hands out via DHCP (shouldn't change unless you recreate the VM):
		
		VBoxManage controlvm "Arch-testbed" poweroff ; VBoxManage snapshot "Arch-testbed" restore "ssh" && VBoxManage startvm "Arch-testbed" --type headless && sleep 5 && sshpass -p "root" ssh root@192.168.56.101 "USER=ryan PASS=ryan HOSTNAME=vbox bash <(curl -L http://git.io/va6Ei)"

