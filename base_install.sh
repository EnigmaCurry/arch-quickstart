#!/bin/bash
# Automatic Arch install script
# Ryan McGuire <ryan@enigmacurry.com>
# http://github.com/EnigmaCurry/arch-quickstart

# This script will automatically perform a base install from the
# official Arch Install ISO, performing all the steps, hands-free.

# NOTE: This is not the 'Arch Way' of installing Arch Linux. Please
# follow the Beginners Guide if you're unfamiliar with the regular
# Arch install: https://wiki.archlinux.org/index.php/Beginners%27_guide

# This script will only install to a blank drive. If you already have
# a partition table on your drive, you will need to erase that first
# before using this script. This is a precaution to not accidentally
# delete the wrong partition. Here is a command to do that, assuming
# your drive is /dev/sda:

## DON'T RUN THIS IF YOU DON'T WANT TO WIPE YOUR DRIVE:
##
##   dd if=/dev/zero of=/dev/sda bs=100M count=1
## 
## You will need to reboot again after running that, otherwise parted
## will still think the partition table exists.

# How to use this script:
#  1) Ensure your drive is blank (see above)
#  2) Boot the regular Arch Install ISO from https://www.archlinux.org/download/
#  3) Ensure you have a network connection. Wired should come up
#     automatically. For wifi use 'wifi-menu' command.
#  4) Run the following command, specifying any of the environment
#     variables below (or don't and just use the defaults):
#     curl -L https://git.io/va6Ei > base_install && INSTALL_DEVICE=/dev/sda HOSTNAME=lappy bash base_install.sh

# Default install parameters. Change them here in this script, or pass
# them in as environment variables:
[ -z "$INSTALL_DEVICE" ] && INSTALL_DEVICE=/dev/sda
[ -z "$LVM_NAME" ] && LVM_NAME=arch
[ -z "$ROOT_SIZE" ] && ROOT_SIZE=30G
[ -z "$SWAP_SIZE" ] && SWAP_SIZE=8G # 0 will disable swap creation
[ -z "$LANG" ] && LANG=en_US.UTF-8
[ -z "$LOCALE" ] && LOCALE=America/New_York
[ -z "$HOSTNAME" ] && HOSTNAME=arch
[ -z "$ARCH_QUICKSTART_REPO" ] && ARCH_QUICKSTART_REPO="https://github.com/EnigmaCurry/arch-quickstart.git"
# Target to run:
#  base_install - Install just the base Arch Linux
#  full_install - Install base Arch and then invoke salt files
[ -z "$TARGET" ] && TARGET="full_install"

# This is my own personal Arch mirror, using https://github.com/EnigmaCurry/lazy-distro-mirrors
# You can comment it out, provide your own, or just leave as-is. This
# script will test to make sure the mirror is reachable, otherwise it
# will just use the default Arch mirrorlist.
[ -z "$ARCH_MIRROR" ] && ARCH_MIRROR='http://kernel-mirror:9080/archlinux/$repo/os/$arch'

# Username and password are asked interactively by default, but you
# can comment these out or set in the environment too:
#[ -z "$USER" ] && USER=ryan
#[ -z "$PASS" ] && PASS=ryan

# You can replace the default pillar data (pillar/data.sls) with your
# own customizations via the PILLAR_DATA variable. With the default
# ARCH_QUICKSTART_REPO and no PILLAR_DATA passed in, your new user
# account will have the default dotfiles from EnigmaCurry/dotfiles.
# Note that the PILLAR_DATA overwrites the default data in pillar/data.

echo

# Fail fast if we get into trouble:
set -e

# Functions to display commands
exe() { echo "\$ $@" ; "$@" ; }
exe_true() { echo "\$ $@" ; "$@" || true ; }

# Function to ensure a device name exists
device_exists() {
    set +e
    lsblk $1 -n -o name -p > /dev/null 2>&1;
    if [ $? != 0 ]; then
	echo "# Device $1 should exist, but it doesn't. Can't continue."
	exit 1
    fi
    set -e
}

get_lvm_device() {
    lvdisplay $LVM_NAME/$1 | grep "LV Path" | awk '{ print $3 }'
}

echo ""

if [ `hostname` != "archiso" ]; then
    echo "# Hostname is expected to be 'archiso' but it's not."
    echo "# Are you running the Arch Install ISO?"
    exit 1
else
    echo "# Looks like we're running the Arch Install ISO, great."
fi

# Ensure the install device is empty before continuing:
device_exists $INSTALL_DEVICE
echo "### Checking to ensure install device is blank"
set +e; BLANK_PARTITION_TABLE=$(parted -s $INSTALL_DEVICE print 2>&1 | grep -ic "Partition Table: unknown"); set -e
if [ $BLANK_PARTITION_TABLE -eq 0 ]; then
    echo "# Your INSTALL_DEVICE already has a partition table."
    echo "# In order to use this tool, the INSTALL_DEVICE must be blank."
    echo "You can wipe it with the following command (careful!): "
    echo "  dd if=/dev/zero of=$INSTALL_DEVICE bs=100M count=1"
    echo "Afterward you need to reboot and run this install script again."
    exit 1
fi

if [ -z "$USER" ]; then
    echo "Username was not specified in environment"
    read -p "Enter the username to create:" USER
fi

if [ -z "$PASS" ]; then
    echo "User password was not specified in environment"
    while :
    do
	stty -echo
	read -p "Enter a password for the $USER account:" PASS
	echo
	read -p "Verify password:" VERIFY_PASS
	echo
	stty echo
	if [ $PASS == $VERIFY_PASS ]
	then
	    break
	else
	    echo
	    echo "Passwords did not match, try again"
	fi
    done
fi
[ -z "$ROOT_PASS" ] && ROOT_PASS=$PASS


echo "### Set system clock"
exe timedatectl set-ntp true

echo "### Create partitions"
exe parted -s $INSTALL_DEVICE mklabel msdos
exe parted -s $INSTALL_DEVICE mkpart primary 2048s 100%
exe parted -s $INSTALL_DEVICE set 1 lvm on
sleep 2

echo "### Prepare LVM device"
LVM_DEVICE="$INSTALL_DEVICE"1
# Check device is ready:
device_exists $LVM_DEVICE
exe pvcreate $LVM_DEVICE
exe vgcreate $LVM_NAME $LVM_DEVICE
if [ $SWAP_SIZE != 0 ]; then
    exe yes | lvcreate -L $SWAP_SIZE $LVM_NAME -n swap
fi
exe yes | lvcreate -L $ROOT_SIZE $LVM_NAME -n root
exe yes | lvcreate -l +100%FREE $LVM_NAME -n home

echo "### Create filesystems:"
if [ $SWAP_SIZE != 0 ]; then
    exe mkswap -L swap $(get_lvm_device swap)
    swapon $(get_lvm_device swap)
fi
exe mkfs.ext4 $(get_lvm_device root)
exe mkfs.ext4 $(get_lvm_device home)

if [ -n "$ARCH_MIRROR" ]; then
    echo "### Set custom Arch mirror"
    # Test that the mirror is reachable.
    # This returns 404, but that at least means the server is there.
    curl -I $ARCH_MIRROR > /dev/null 2>&1
    if [ $? == 0 ]
    then
	echo "Server = $ARCH_MIRROR" > /etc/pacman.d/mirrorlist
    fi
fi

echo "### Mount filesystems:"
exe mount $(get_lvm_device root) /mnt
exe mkdir /mnt/home
exe mount $(get_lvm_device home) /mnt/home
echo "### Install base system:"
exe yes "" | pacstrap -i /mnt base base-devel

echo "### Perform chroot tasks:"
exe genfstab -U -p /mnt >> /mnt/etc/fstab
cat <<EOF | arch-chroot /mnt /bin/bash
  echo $LANG UTF-8 >> /etc/locale.gen
  locale-gen
  echo LANG=$LANG > /etc/locale.conf
  ln -s /usr/share/zoneinfo/$LOCALE /etc/localtime
  hwclock --systohc --utc
  echo $HOSTNAME > /etc/hostname
  systemctl enable dhcpcd.service
  sed -i 's/^HOOKS=.*/HOOKS="base udev autodetect modconf block keyboard lvm2 filesystems fsck"/' /etc/mkinitcpio.conf
  mkinitcpio -p linux
  pacman -S --noconfirm grub
  grub-mkconfig -o /boot/grub/grub.cfg
  grub-install $INSTALL_DEVICE
  chmod -R g-rwx,o-rwx /boot
  echo root:$ROOT_PASS | chpasswd
EOF

## Done with base_install
if [ $TARGET == "full_install" ]; then
    echo "base_install finished. Continuing with saltstack install."
else if
    echo "Arch base installation finished. Reboot now and remove the installation media."
    exit 0
fi
    
cat <<EOF | arch-chroot /mnt /bin/bash
  pacman -S --noconfirm git salt-zmq
  git clone $ARCH_QUICKSTART_REPO /root/arch-quickstart
EOF

if [ -v "PILLAR_DATA" ]; then
    echo "$PILLAR_DATA" > /mnt/root/arch-quickstart/pillar/data.sls
else
    cat <<EOF > /mnt/root/arch-quickstart/pillar/users/init.sls
user: ryan

groups:
  $USER: 1000

users:
  $USER:
   uid: 1000
   gid: 1000
   groups:
     - wheel
EOF
fi    

cat <<EOF | arch-chroot /mnt /bin/bash
  cd /root/arch-quickstart
  ./user_bootstrap.sh
  echo $USER:$PASS | chpasswd
EOF

echo
echo "Install finished. Reboot now and remove the installation media."
