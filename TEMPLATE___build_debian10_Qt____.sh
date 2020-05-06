#!/bin/bash

export HOST_PASS=                                           # password for superuser on your host machinve (uses in core/00-init.sh, function preAuthRoot to automate building process)
export DEV_PASS=                                            # password for superuser on your device
export DEV_HOSTNAME=                                        # hostname is what device is called on a network

export IMG_SIZE_MB=2000                                     # whole size of the target image file (+additional space for boot, ~50Mb)
export IMG_NAME="debian10-$(date '+%d%m%Y-%H%M%S').img"     # the name of the target image
export IMG_FMT_ON_MNT="a"                                   # SYSROOT drive in image will formatted if it hasn't any filesystem

export TC_URL=                                              # needed toolchain for crosscompilation under your target device

export UBOOT_GITURL=                                        # git URL of u-Boot repository for your target device
export UBOOT_BRANCH=                                        # branch of u-Boot repository for your target device
export UBOOT_CONFIG=                                        # current configuration of u-Boot for your target device
export UBOOT_RECOMPILE="y"                                  # try to do compilation even u-Boot is already pre-compiled
export UBOOT_CLEAN="n"                                      # to clean source code before compilation
export UBOOT_PRECOMPILE=                                    # path to script, which placed into ${USERDIR}, will called before compilation of u-Boot; can be used to apply some patches, etc.
export UBOOT_POSTINSTALL=                                   # path to script, which placed into ${USERDIR}, will called after installation of u-Boot

export KERNEL_GITURL=                                       # git URL of the Linux Kernel repository for your target device
export KERNEL_BRANCH=                                       # branch of the Linux Kernel for your target device
export KERNEL_CONFIG=                                       # current configuration of the Linux Kernel for your target device
export KERNEL_DTB=                                          # current devices tree of the Linux Kernel for your target device
export KERNEL_RECOMPILE="y"                                 # try to do compilation even Linux Kernel is already pre-compiled
export KERNEL_CLEAN="n"                                     # to clean source code before compilation
export KERNEL_PRECOMPILE=                                   # path to script, which placed into ${USERDIR}, will called before compilation of the Linux Kernel; can be used to apply some patches, etc.
export KERNEL_POSTINSTALL=                                  # path to script, which placed into ${USERDIR}, will called after installation of the Linux Kernel

export HOST_MMC="/dev/sdb"                                  # target bootable MMC on your host machine, where image ${IMG_NAME} will be writed
export DEV_STORAGE_FS="exfat"                               # filesystem of drive "Storage", which be created in whole free space
export DEV_STORAGE_LBL="STORAGE"                            # disk label of drvie "Storage"
export DEV_STORAGE_OTG="y"                                  # access to drive "Storage" will be available through USB-OTG
export DEV_FSTAB_MMC_PREFIX="mmcblk1p"                      # prefix of target bootable MMC on your device

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

export Qt_VER="5.12"                                        # needed version of Qt
export Qt_DEVICE="imx6"                                     # type of target device
export Qt_INSTALL_SDK="y"                                   # will create the medium copy of Qt, placed in ${CACHE} on you host machine
export Qt_RECOMPILE="a"                                     # a - "auto", will compile only of it wasn't successfully compiled before
export Qt_ACCEPT_CONFIG="y"                                 # y - "yes", will accept OPENSOURCE LICENSE (!!!) automatically

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
    if ! ( bash "05-sysroot_debian10_create_Qt.sh" )        ; then showElapsedTime ; exit 05 ; fi
    if ! ( bash "06-build_kernel.sh" )                      ; then showElapsedTime ; exit 06 ; fi
    if ! ( bash "07-install_kernel.sh" )                    ; then showElapsedTime ; exit 07 ; fi
    if ! ( bash "08-install_uboot.sh" )                     ; then showElapsedTime ; exit 08 ; fi
    if ! ( bash "09-sysroot_configure.sh" )                 ; then showElapsedTime ; exit 09 ; fi
popd

pushd "${USERDIR}"
    if ! ( bash "configure_mcp1_sysroot.sh" )               ; then showElapsedTime ; exit 10 ; fi
    if ! ( bash "install_systemd_bootsplash.sh" )           ; then showElapsedTime ; exit 10 ; fi
    if ! ( bash "install_rtl8188eu.sh" )                    ; then showElapsedTime ; exit 10 ; fi
    if ! ( bash "imx/install_imx_gpu.sh" )                  ; then showElapsedTime ; exit 10 ; fi
    if ! ( bash "imx/install_imx_vpu_gst.sh" )              ; then showElapsedTime ; exit 10 ; fi
    if ! ( bash "install_Qt.sh" )                           ; then showElapsedTime ; exit 10 ; fi
    # ...
    # HERE ARE YOUR OWN SCRIPTS, PLACED INTO ${USERDIR}:
    #    if ! ( bash "THE_NAME_OF_YOUR_OWN_SCRIPT.sh" )     ; then showElapsedTime ; exit 10 ; fi
    # ...
    # ...
popd

clean_all

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --
#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

if ! ( bash "core/10-flash_image.sh" )                      ; then showElapsedTime ; exit 11 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

echo ""
echo "    DONE ; target image -- ${IMG_NAME}"
echo ""

showElapsedTime ; exit 0
