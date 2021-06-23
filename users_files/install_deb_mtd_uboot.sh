#!/bin/bash
show_current_task

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

install_deb_pkgs mtd-utils

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

install_uboot_file() {

    preAuthRoot && sudo mkdir -p "${SYSROOT}/opt/mtd_uboot"
    if [ -f "${CACHE}/${UBOOT_GITREPO}-${UBOOT_BRANCH}/$1" ] ; then
        if ! ( preAuthRoot && sudo install -m 0755 "${CACHE}/${UBOOT_GITREPO}-${UBOOT_BRANCH}/$1" "${SYSROOT}/opt/mtd_uboot/" ) ; then goto_exit 1 ; fi
    fi
}

install_uboot_file "SPL"
install_uboot_file "u-boot.bin"
install_uboot_file "u-boot.img"
install_uboot_file "u-boot.imx"

preAuthRoot
echo "#!/bin/bash
cd /opt/mtd_uboot
dd if=/dev/zero of=/tmp/prefix bs=1024 count=1
cat /tmp/prefix ./u-boot.imx > /tmp/u-boot_nor.imx
flash_erase /dev/mtd0 0 0
if ! ( flashcp -v /tmp/u-boot_nor.imx /dev/mtd0 ) ; then
    echo 'Unable to write u-boot. Try to unlock SPI-NOR flash via \"sf probe 0:0\" in loaded u-boot, then try again.'
    exit 1
fi
sync
" | sudo tee "${SYSROOT}/opt/mtd_uboot/install.sh"
preAuthRoot && sudo chmod +x "${SYSROOT}/opt/mtd_uboot/install.sh"
