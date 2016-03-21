VM='Arch-testbed'
THIS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
VM_DIR=$THIS_DIR/vm

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
echo "echo 'hi quickstart'" > squashfs-root/root/.zshrc.local
mksquashfs squashfs-root airootfs.sfs
rm -rf squashfs-root
md5sum airootfs.sfs > airootfs.md5
EOF

perl -pi -e 's/archisolabel=ARCH_[0-9]*/archisolabel=ARCH_QUICKSTART/' $REMASTER/loader/entries/archiso-x86_64.conf $REMASTER/arch/boot/syslinux/archiso_sys32.cfg $REMASTER/arch/boot/syslinux/archiso_sys64.cfg

cd $REMASTER
genisoimage -l -r -J -V $ISO_LABEL -b isolinux/isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -c isolinux/boot.cat -o $ARCH_QUICKSTART_ISO .

