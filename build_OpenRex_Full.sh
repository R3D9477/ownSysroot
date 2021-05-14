#!/bin/bash

source "core/00-func.sh"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --
# SETTINGS --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ----

    # BASE SETTINGS

exportdefvar CACHE                      "$HOME/ownSysroot-dev/cache"
exportdefvar MOUNT                      "$HOME/ownSysroot-dev/mount"
exportdefvar IMGDIR                     "$HOME/ownSysroot-dev/image"

exportdefvar REMOVE_IMG                 y
exportdefvar FLASH_IMG                  y

exportdefvar HOST_PASS                  ""
exportdefvar DEV_PASS                   "ownSysroot"
exportdefvar DEV_HOSTNAME               "ownSysroot"

exportdefvar IMG_SIZE_MB                3500
exportdefvar IMG_NAME                   "ownSysroot-openrex.img"
exportdefvar IMG_FMT_ON_MNT             y

exportdefvar TC_URL                     "https://releases.linaro.org/components/toolchain/binaries/latest-5/arm-linux-gnueabihf/gcc-linaro-5.5.0-2017.10-x86_64_arm-linux-gnueabihf.tar.xz"
exportdefvar GENERATE_MESON_INI         y

exportdefvar UBOOT_GITURL               "https://github.com/voipac"
exportdefvar UBOOT_GITREPO              "uboot-imx"
exportdefvar UBOOT_BRANCH               "uboot-imx-v2015.04"
exportdefvar UBOOT_CONFIG               "mx6openrexbasic_config"
exportdefvar UBOOT_PRECOMPILE           ""
exportdefvar UBOOT_RECOMPILE            n
exportdefvar UBOOT_CLEAN                n
exportdefvar UBOOT_POSTINSTALL          "uboot-config/uboot_postinstall.sh"

exportdefvar KERNEL_GITURL              "https://github.com/voipac"
exportdefvar KERNEL_GITREPO             "linux-fslc"
exportdefvar KERNEL_BRANCH              "4.1-2.0.x-imx-rex"
exportdefvar KERNEL_CONFIG              "imx_v7_defconfig"
exportdefvar KERNEL_DTB                 "imx6-openrexbasic.dtb"
exportdefvar KERNEL_PRECOMPILE          ""
exportdefvar KERNEL_RECOMPILE           n
exportdefvar KERNEL_CLEAN               n

exportdefvar FLASH_IMG                  y
exportdefvar HOST_MMC                   "/dev/sdb"

exportdefvar DEV_MAKE_STORAGE           y
exportdefvar DEV_FSTAB_MMC_PREFIX       "sda"
exportdefvar DEV_STORAGE_FS             "exfat"
exportdefvar DEV_STORAGE_LBL            "STORAGE"

exportdefvar DEV_USBOTG                 y
exportdefvar DEV_USBOTG_AUTOINSERT      n

exportdefvar DEV_POSTCONFIG             ""

    # USER'S SETTINGS

exportdefvar rtl8188eu_RECOMPILE        n
exportdefvar ffmpeg_RECOMPILE           n
exportdefvar ffmpeg_EXTRAARGS           ' '
exportdefvar gst_RECOMPILE              n

exportdefvar Qt_VER                     "5.15"
exportdefvar Qt_DEVICE                  "imx6"
exportdefvar Qt_OPENGL                  "es2"
exportdefvar Qt_RECOMPILE               n
exportdefvar Qt_OPENSOURCE              y
exportdefvar Qt_ACCEPT_CONFIG           y
exportdefvar Qt_MAKE_BINBCK             y
exportdefvar Qt_INSTALL_BINBCK          y

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --
# IMAGE BUILDING --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

source "core/00-init.sh"
source "core/01-set_tc.sh"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

    # BUILD BASE IMAGE

clean_all "${REMOVE_IMG}"

pushd "${COREDIR}"
    if ! ( bash "02-build_uboot.sh" )                       ; then goto_exit 002 ; fi
    if ! ( bash "03-create_bootable_img.sh" )               ; then goto_exit 003 ; fi
    if ! ( bash "04-mount_img.sh" )                         ; then goto_exit 004 ; fi
    if ! ( bash "05-sysroot_debian10_create_Qt.sh" )        ; then goto_exit 005 ; fi
    if ! ( bash "06-build_kernel.sh" )                      ; then goto_exit 006 ; fi
    if ! ( bash "07-install_kernel.sh" )                    ; then goto_exit 007 ; fi
    if ! ( bash "08-install_uboot.sh" )                     ; then goto_exit 008 ; fi
    if ! ( bash "09-configure_sysroot.sh" )                 ; then goto_exit 009 ; fi
popd

    # ADD USER'S PACKAGES

pushd "${USERDIR}"
    if ! ( bash "install_ffmpeg.sh" )                       ; then goto_exit 100 ; fi
    if ! ( bash "imx/install_imx_gpu.sh" )                  ; then goto_exit 101 ; fi
    if ! ( bash "imx/install_imx_vpu_cc.sh" )               ; then goto_exit 102 ; fi
    if ! ( bash "install_gstreamer-1.0.sh" )                ; then goto_exit 103 ; fi  # Depends on GL/GLES/EGL
    if ! ( bash "imx/install_imx_gst_cc.sh" )               ; then goto_exit 104 ; fi
    if ! ( bash "install_v4l2loopback.sh" )                 ; then goto_exit 105 ; fi
    if ! ( bash "install_Qt.sh" )                           ; then goto_exit 106 ; fi
    if ! ( bash "install_ftpserver.sh" )                    ; then goto_exit 107 ; fi
    if ! ( bash "install_rtl8188eu.sh" )                    ; then goto_exit 108 ; fi
    if ! ( bash "install_wifiap.sh" )                       ; then goto_exit 109 ; fi
    if ! ( bash "install_avrdude.sh" )                      ; then goto_exit 110 ; fi
    if ! ( bash "install_spi-test.sh" )                     ; then goto_exit 111 ; fi
popd

    # APPLY USER'S SYSROOT CONFIG

pushd "${USERDIR}"
    if ! ( bash "configure_autologin.sh" )                  ; then goto_exit 200 ; fi
    if ! ( bash "configure_disable_eth.sh" )                ; then goto_exit 201 ; fi
popd

    # USER'S APPLICATIONS

pushd "${USERDIR}"
    #if ! ( bash "install_QtApp.sh" "$HOME/path/to/my/own/Qt/Application/Folder" ) ; then goto_exit 300 ; fi
    #...
popd

clean_all

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

    # MAKE BOOTABLE DRVIE

if [ "${FLASH_IMG}" != "n" ] ; then
    if ! ( bash "core/10-flash_image.sh" )                  ; then goto_exit 500 ; fi
fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --
#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

show_message "DONE ; target image -- ${IMG_NAME}"
