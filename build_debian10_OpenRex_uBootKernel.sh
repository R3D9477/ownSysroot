#!/bin/bash

export HOST_PASS=
export DEV_PASS="root"
export DEV_HOSTNAME="IMX6DEB"

export IMG_SIZE_MB=50
export IMG_NAME="debian10-openrex-$(date '+%d%m%Y-%H%M%S').img"
export IMG_FMT_ON_MNT="a"

export TC_URL="https://releases.linaro.org/components/toolchain/binaries/latest-5/arm-linux-gnueabihf/gcc-linaro-5.5.0-2017.10-x86_64_arm-linux-gnueabihf.tar.xz"

export UBOOT_GITURL="https://github.com/voipac/uboot-imx.git"
export UBOOT_BRANCH="uboot-imx-v2015.04"
export UBOOT_CONFIG="mx6openrexbasic_config"
export UBOOT_RECOMPILE="y"
export UBOOT_CLEAN="n"
export UBOOT_PRECOMPILE=
export UBOOT_POSTINSTALL="uboot-config/uboot_postinstall.sh"

export KERNEL_GITURL="https://github.com/voipac/linux-fslc.git"
export KERNEL_BRANCH="4.1-2.0.x-imx-rex"
export KERNEL_CONFIG="imx_v7_defconfig"
export KERNEL_DTB="imx6-openrexbasic.dtb"
export KERNEL_RECOMPILE="y"
export KERNEL_CLEAN="n"
export KERNEL_PRECOMPILE="mcp1-kernel-openrex/install.sh"
export KERNEL_POSTINSTALL=

export HOST_MMC="/dev/sdb"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --
#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

source "core/00-init.sh"
source "core/01-set_tc.sh"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --
#--- WORKING DISTRO --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

clean_all "y"

pushd "${COREDIR}"
    if ! ( bash "02-build_uboot.sh" )                       ; then showElapsedTime ; exit 02 ; fi
    if ! ( bash "03-create_bootable_img.sh" )               ; then showElapsedTime ; exit 03 ; fi
    if ! ( bash "04-mount_img.sh" )                         ; then showElapsedTime ; exit 04 ; fi
    if ! ( bash "06-build_kernel.sh" )                      ; then showElapsedTime ; exit 06 ; fi
    if ! ( bash "07-install_kernel.sh" )                    ; then showElapsedTime ; exit 07 ; fi
    if ! ( bash "08-install_uboot.sh" )                     ; then showElapsedTime ; exit 08 ; fi
popd

clean_all

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --
#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

if ! ( bash "core/10-flash_image.sh" )                      ; then showElapsedTime ; exit 09 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

echo ""
echo "    DONE ; target image -- ${IMG_NAME}"
echo ""

showElapsedTime ; exit 0
