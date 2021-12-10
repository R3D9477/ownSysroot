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

exportdefvar HOST_PASS                  "root"
exportdefvar DEV_PASS                   "root"
exportdefvar DEV_HOSTNAME               "ownSysroot"

exportdefvar IMG_SIZE_MB                2000
exportdefvar IMG_NAME                   "ownSysroot-openrex.img"
exportdefvar IMG_FMT_ON_MNT             y

exportdefvar TC_URL                     "https://releases.linaro.org/components/toolchain/binaries/latest-7/arm-linux-gnueabihf/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz"
exportdefvar GENERATE_MESON_INI         y

exportdefvar UBOOT_GITURL               "https://github.com/voipac"
exportdefvar UBOOT_GITREPO              "uboot-imx"
exportdefvar UBOOT_BRANCH               "uboot-imx-v2015.04"
exportdefvar UBOOT_CONFIG               "mx6openrexbasic_config"
exportdefvar UBOOT_PATCH                ""
exportdefvar UBOOT_RECOMPILE            n
exportdefvar UBOOT_CLEAN                n
exportdefvar UBOOT_POSTINSTALL          "uboot-config/uboot_postinstall.sh"

exportdefvar KERNEL_GITURL              "https://github.com/voipac"
exportdefvar KERNEL_GITREPO             "linux-fslc"
exportdefvar KERNEL_BRANCH              "4.1-2.0.x-imx-rex"
exportdefvar KERNEL_CONFIG              "imx_v7_defconfig"
exportdefvar KERNEL_DTB                 "imx6-openrexbasic.dtb"
exportdefvar KERNEL_PATCH               ""
exportdefvar KERNEL_RECOMPILE           n
exportdefvar KERNEL_CLEAN               n

exportdefvar FLASH_IMG                  y
exportdefvar HOST_MMC                   "/dev/sdb"

exportdefvar DEV_MAKE_STORAGE           y
exportdefvar DEV_FSTAB_MMC_PREFIX       "sda"
exportdefvar DEV_STORAGE_FS             "exfat"
exportdefvar DEV_STORAGE_LBL            "STORAGE"

exportdefvar DEV_USBOTG_DEVICE          "/dev/${DEV_FSTAB_MMC_PREFIX}3"
exportdefvar DEV_USBOTG_idVendor        "0"
exportdefvar DEV_USBOTG_iManufacturer   "0"
exportdefvar DEV_USBOTG_idProduct       "0"
exportdefvar DEV_USBOTG_iSerialNumber   "0"
exportdefvar DEV_USBOTG_bcdDevice       "0"
exportdefvar DEV_USBOTG_inquiry_string  "ownSysroot-${DEV_STORAGE_LBL}"

exportdefvar DEV_POSTCONFIG             ""

    # USER'S SETTINGS

#exportdefvar gst_PATCH                  "imx/patch_gstreamer.sh"
exportdefvar gst_RECOMPILE              n
exportdefvar gst_MESON_OPS              "-Dgst-plugins-base:gio=disabled -Dgst-plugins-bad:opencv=disabled -Dorc=disabled -Dexamples=disabled -Dgst-plugins-good:qt5=enabled -Dgst-plugins-base:gl_api=gles2 -Dgst-plugins-base:gl_platform=egl -Dgst-plugins-base:gl_winsys=egl"
    
exportdefvar ffmpeg_EXTRAARGS           " "

exportdefvar Qt_VER                     "5.15"
exportdefvar Qt_DEVICE                  "imx6"
exportdefvar Qt_OPENGL                  "es2"
exportdefvar Qt_RECOMPILE               n
exportdefvar Qt_OPENSOURCE              y
exportdefvar Qt_ACCEPT_CONFIG           y
exportdefvar Qt_MAKE_BINBCK             y
exportdefvar Qt_INSTALL_BINBCK          y

exportdefvar Qt_PATCH                   "imx/patch_qt.sh"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --
# IMAGE BUILDING --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

source "core/00-init.sh"
source "core/01-set_tc.sh"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

clean_all "${REMOVE_IMG}"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

# BUILD BASE IMAGE

    pushd "${COREDIR}"
        if ! ( bash "02-build_uboot.sh" )                       ; then goto_exit 002 ; fi
        if ! ( bash "03-create_bootable_img.sh" )               ; then goto_exit 003 ; fi
        if ! ( bash "04-mount_img.sh" )                         ; then goto_exit 004 ; fi
        if ! ( bash "05-sysroot_debian10_Qt.sh" )               ; then goto_exit 005 ; fi
        if ! ( bash "06-build_kernel.sh" )                      ; then goto_exit 006 ; fi
        if ! ( bash "07-install_kernel.sh" )                    ; then goto_exit 007 ; fi
        if ! ( bash "08-install_uboot.sh" )                     ; then goto_exit 008 ; fi
        if ! ( bash "09-configure_sysroot.sh" )                 ; then goto_exit 009 ; fi
    popd

# ADD USER'S PACKAGES
    
    pushd "${USERDIR}"
        if ! ( bash "install_deb_libc6dev.sh" )                 ; then goto_exit 100 ; fi
        if ! ( bash "install_deb_xml2.sh" )                     ; then goto_exit 101 ; fi
        if ! ( bash "install_deb_gobj.sh" )                     ; then goto_exit 102 ; fi
        if ! ( bash "install_cc_ffmpeg.sh" )                    ; then goto_exit 103 ; fi
        if ! ( bash "install_deb_v4l-utils.sh" )                ; then goto_exit 104 ; fi
        if ! ( bash "install_deb_wifiap.sh" )                   ; then goto_exit 105 ; fi
        if ! ( bash "install_deb_ftpserver.sh" )                ; then goto_exit 106 ; fi
        if ! ( bash "install_deb_i2c_tools.sh" )                ; then goto_exit 107 ; fi
        if ! ( bash "install_cc_avrdude.sh" )                   ; then goto_exit 108 ; fi
        if ! ( bash "install_cc_spi-test.sh" )                  ; then goto_exit 109 ; fi
        if ! ( bash "install_deb_socat.sh" )                    ; then goto_exit 110 ; fi
        if ! ( bash "install_deb_cpulimit.sh" )                 ; then goto_exit 111 ; fi
        if ! ( bash "install_deb_cpufreq.sh" )                  ; then goto_exit 112 ; fi
        if ! ( bash "install_deb_lsof.sh" )                     ; then goto_exit 113 ; fi
    popd

# ADD i.mx6 GPU/VPU

    pushd "${USERDIR}"
        if ! ( bash "imx/install_bin_imx_gpu.sh" )              ; then goto_exit 200 ; fi
        if ! ( bash "imx/install_cc_imx_vpu.sh" )               ; then goto_exit 201 ; fi
    popd

# ADD Qt ( without QtMultimedia )

    pushd "${USERDIR}"
        export Qt_INSTALL_MM=n                                  # build all but QtMultimedia
        export Qt_MAKE_BINBCK=n                                 # don't make package with Qt binaries
        if ! ( bash "install_cc_Qt.sh" )                        ; then goto_exit 300 ; fi
    popd
    
# ADD GStreamer-1.0

    pushd "${USERDIR}"
        if ! ( bash "install_cc_gstreamer-1.0.sh" )             ; then goto_exit 400 ; fi  # depends on GL/GLES/EGL and Qt (base+quick)
        if ! ( bash "imx/install_cc_imx_gst.sh" )               ; then goto_exit 401 ; fi  
    popd

# ADD Qt Multimedia

    pushd "${USERDIR}"
        export Qt_INSTALL_QML=n                                 # don't rebuild again
        export Qt_INSTALL_SERIAL=n                              # don't rebuild again
        export Qt_INSTALL_MM=y                                  # build and install QtMultimedia
        export Qt_MAKE_BINBCK=y                                 # make final package with all Qt binaries
        if ! ( bash "install_cc_Qt.sh" )                        ; then goto_exit 500 ; fi
    popd

# ADD USER'S DRIVERS

    pushd "${USERDIR}"
        if ! ( bash "install_cc_v4l2loopback.sh" )              ; then goto_exit 602 ; fi
        if ! ( bash "install_cc_rtl8188eus.sh" )                ; then goto_exit 603 ; fi
    popd

# APPLY USER'S SYSROOT CONFIG

    pushd "${USERDIR}"
        if ! ( bash "configure_autologin.sh" )                  ; then goto_exit 700 ; fi
        if ! ( bash "configure_disable_eth.sh" )                ; then goto_exit 701 ; fi
        if ! ( bash "configure_usbotg.sh" )                     ; then goto_exit 702 ; fi
    popd

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

clean_all

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

# MAKE BOOTABLE DRVIE

    if [ "${FLASH_IMG}" != "n" ] ; then
        if ! ( bash "core/10-flash_image.sh" )                  ; then goto_exit 010 ; fi
    fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --
#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

show_message "DONE ; target image -- ${IMG_NAME}"
