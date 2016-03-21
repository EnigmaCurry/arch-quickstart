#!/bin/bash

# Helper script to setup a VirtualBox VM for testing arch-quickstart

# This script will create the initial VM.

# This doesn't automate everything, once the VM is created this tool
# will tell you some commands to type into the console to setup
# networking. Once you get it all setup, you'll create a snapshot, and
# you shouldn't have to run this script again.

set -e
VM='Arch-testbed'
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VM_DIR=$THIS_DIR/vm
HOST_IP=`python -c "import socket; print(socket.gethostbyname(socket.gethostname()))"`
FREE_PORT=`python -c "import socket; s=socket.socket(socket.AF_INET, socket.SOCK_STREAM); s.bind(('',0)); print(s.getsockname()[1])"`
FREE_PORT2=`python -c "import socket; s=socket.socket(socket.AF_INET, socket.SOCK_STREAM); s.bind(('',0)); print(s.getsockname()[1])"`

# Function to display commands
exe() { echo "\$ $@" ; "$@" ; }
exe_true() { echo "\$ $@" ; "$@" || true ; }

[ -z "DESTROY" ] && DESTROY=false
if [ "$DESTROY" == "true" ]; then
    exe_true VBoxManage controlvm $VM poweroff && sleep 1
    exe_true VBoxManage unregistervm $VM --delete
    exe_true VBoxManage closemedium disk $VM_DIR/$VM.vdi --delete
    exe_true rm -rf $VM_DIR
fi

set +e
VBoxManage showvminfo $VM > /dev/null 2>&1
VM_STATE=$?
set -e
if [ "$VM_STATE" -eq 0 ]; then
    echo "VM already exists - pass DESTROY=true to this script to delete the previous VM"
    exit 1
fi
if [ ! -f $THIS_DIR/arch.iso ]; then
    echo "You must download the Arch iso and copy/link it to $THIS_DIR/arch.iso"
    exit 1
fi

######################################################################
## Remaster arch iso
######################################################################

#ISO_LABEL=`isoinfo -d -i $THIS_DIR/arch.iso | grep "Volume id" | awk '{print $3}'`
ISO_LABEL='ARCH_QUICKSTART'
ARCH_QUICKSTART_ISO=$THIS_DIR/arch-quickstart.iso

rm $ARCH_QUICKSTART_ISO
rm -rf $THIS_DIR/iso_remaster
mkdir -p $THIS_DIR/iso_remaster
cd $THIS_DIR/iso_remaster
7z x ../arch.iso
REMASTER=$THIS_DIR/iso_remaster

cat <<EOF | sudo bash
cd $REMASTER/arch/x86_64/
unsquashfs airootfs.sfs && rm airootfs.sfs
echo "sleep 5 && bash <(curl http://$HOST_IP:$FREE_PORT)" > squashfs-root/root/.zshrc.local
mksquashfs squashfs-root airootfs.sfs
rm -rf squashfs-root
md5sum airootfs.sfs > airootfs.md5
EOF

perl -pi -e 's/archisolabel=ARCH_[0-9]*/archisolabel=ARCH_QUICKSTART/' $REMASTER/loader/entries/archiso-x86_64.conf $REMASTER/arch/boot/syslinux/archiso_sys32.cfg $REMASTER/arch/boot/syslinux/archiso_sys64.cfg
echo "TIMEOUT 5" >> $REMASTER/arch/boot/syslinux/archiso_head.cfg


cd $REMASTER
genisoimage -l -r -J -V $ISO_LABEL -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -c isolinux/boot.cat -o $ARCH_QUICKSTART_ISO .


######################################################################
## Create VM
######################################################################


mkdir -p $VM_DIR && cd $VM_DIR
exe VBoxManage createvm --name $VM --ostype "ArchLinux_64" --register
exe VBoxManage createmedium --filename $VM_DIR/$VM.vdi --size 40000
exe VBoxManage storagectl $VM --name "SATA Controller" --add sata --controller IntelAHCI
exe VBoxManage storageattach $VM --storagectl "SATA Controller" --port 0 --device 0 --type hdd --medium $VM_DIR/$VM.vdi
exe VBoxManage storagectl $VM --name "IDE Controller" --add ide
exe VBoxManage storageattach $VM --storagectl "IDE Controller" --port 0 --device 0 --type dvddrive --medium ../arch-quickstart.iso
exe VBoxManage modifyvm $VM --nic2 hostonly --hostonlyadapter2 'vboxnet0'
exe VBoxManage modifyvm $VM --memory 2048 --vram 128
exe VBoxManage startvm $VM --type sdl
echo "VM is booting, once it is up type the following to perform additional setup on the client:"

# Serve the following script via http to the VM to setup networking and stuff:
cat <<EOF | curlbomb -k -p $FREE_PORT -
#!/bin/bash
# Functions to display commands
exe() { echo "\\\$ \$@" ; "\$@" ; }
exe_true() { echo "\\\$ \$@" ; "\$@" || true ; }

# Stop DHCP clients:
# exe ip -o link show | awk -F': ' '{print \$2}' | xargs -iXX systemctl stop dhcpcd@XX

# Start ssh:
exe pacman -Sy
exe pacman --noconfirm -S openssh
exe systemctl start sshd
echo "root:root" | chpasswd

echo "SSH server started with root password 'root'"
rm ~/.zshrc.local
# Fetch this url to signal to the parent script we're done:
curl http://$HOST_IP:$FREE_PORT2
EOF

# Serve an empty curlbomb again that the client will fetch when the above script completes:
# the above script to signal it being done:
echo "waiting for client to finish"
echo "" | curlbomb -k -q -p $FREE_PORT2 -

exe VBoxManage snapshot $VM take "ssh"
exe VBoxManage controlvm $VM poweroff
exe VBoxManage snapshot $VM restore "ssh"

echo "$VM VM created and 'ssh' snapshot created!"
