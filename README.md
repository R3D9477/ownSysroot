# ownSysroot
System for sysroot building written on pure Bash.

### build_OpenRex_Full.sh:
* script for automated building of Debian-based sysroot for OprenRex board (based on i.mx6 SoC)
    * distributives:
        * [05-sysroot_debian10_base](core/05-sysroot_debian10_base.sh) -- base Debian 10 system
        * [05-sysroot_debian10_Qt](core/05-sysroot_debian10_Qt.sh) -- Debian 10 system + dependencies for Qt cross-compilation
        * [05-sysroot_debian11_base](core/05-sysroot_debian11_base.sh) -- base Debian 11 system
        * [05-sysroot_debian11_Qt](core/05-sysroot_debian11_Qt.sh) -- Debian 11 system + dependencies for Qt cross-compilation
        * [05-sysroot_ubuntu1804_create_base](core/05-sysroot_ubuntu1804_create_base.sh) -- Ubuntu 18 system + dependencies for Qt cross-compilation
    * configs:
        * [configure_autologin](users_files/configure_autologin.sh) - configure autologin (**shell**)
        * [configure_disable_eth](users_files/configure_disable_eth.sh) - configure to disable ethernet (**shell**)
        * [configure_systemd_bootsplash](users_files/configure_systemd_bootsplash.sh) - set a custom logo (**shell**)
        * [configure_usbotg](users_files/configure_usbotg.sh) - configure USB-OTG device
    * i.mx6:
        * [install_bin_imx_gpu](users_files/imx/install_bin_imx_gpu.sh) - install GPU support on i.mx6-based SoM (**binaries**)
        * [install_cc_imx_gst](users_files/imx/install_cc_imx_gst.sh) - install GStreamer 1.0 plugins with VPU/GPU acceleration on i.mx6-based SoM (**cross-compilation**)
        * [install_cc_imx_vpu](users_files/imx/install_cc_imx_vpu.sh) - install VPU support on i.mx6 on i.mx6-based SoM (**cross-compilation**)
        * [install_chr_imx_gst](users_files/imx/install_chr_imx_gst.sh) - install GStreamer 1.0 plugins with VPU/GPU acceleration on i.mx6-based SoM (**chroot**)
        * [install_chr_imx_vpu](users_files/imx/install_chr_imx_vpu.sh) - install VPU support on i.mx6 on i.mx6-based SoM (**chroot**)
    * multimedia:
        * [install_ffmpeg](users_files/install_cc_ffmpeg.sh) - install FFMpeg package (**cross-compilation**)
        * [install_gstreamer-1.0](users_files/install_cc_gstreamer-1.0.sh) - install GStreamer 1.0 package (**cross-compilation**)
        * [install_v4l2loopback](users_files/install_cc_v4l2loopback.sh) - install V4L2 loopback driver (**cross-compilation**)
        * [install_x264](users_files/install_cc_x264.sh) - install x264 libs (**cross-compilation**)
        * [install_v4l-utils](users_files/install_deb_MMC_flasher.sh) -- install v4l2 utilities (**binaries**)
    * drivers:
        * [install_rtl8188eu](users_files/install_cc_rtl8188eu.sh) - install Realtek drvier (**cross-compilation**)
    * services:
        * [install_ftpserver](users_files/install_deb_ftpserver.sh) - install and configure FTP server with anonymous access (**bin-pkg**)
        * [install_wifiap](users_files/install_deb_wifiap.sh) - install WiFi Access point (**bin-pkg**, **shell**)
    * installers:
        * [install_MMC_flasher](users_files/install_deb_MMC_flasher.sh) -- install sysrom from Live USB to device's MMC
        * [install_mtd_uboot](users_files/install_deb_MMC_flasher.sh) -- burn uboot from Live USB to device's MTD
    * Qt:
        * [install_Qt](users_files/install_cc_Qt.sh) - install Qt5 libs (**cross-compilation**)
            * [Qt Core](users_files/Qt/make_qt_base.sh)
            * [Qt Quick2](users_files/Qt/make_qt_quick.sh)
            * [Qt Multimedia](users_files/Qt/make_qt_multimedia.sh)
            * [Qt SerialPort](users_files/Qt/make_qt_serialport.sh)
        * [install_QtApp](users_files/install_cc_QtApp.sh) - install user's custom application (**cross-compilation**)
            * first arg - full path to apllication's directory
            * second arg - application's name
    * Other:
        * [install_spi-test](users_files/install_cc_spi-test.sh) - install application 'spitest' (**cross-compilation**)
        * [install_avrdude](users_files/install_cc_avrdude.sh) - install application 'avrdude' (**cross-compilation**)
        * [install_fbsrc](users_files/install_cc_fbsrc.sh) - install application 'fbsrc' (**cross-compilation**)
        * [install_cpufreq](users_files/install_deb_cpufreq.sh) -- install utility 'cpufreq' (**binaries**)
        * [install_cpulimit](users_files/install_deb_cpufreq.sh) -- install utility 'cpulimit' (**binaries**)
        * [install_gobj](users_files/install_deb_gobj.sh) -- install 'gobject-introspection' (**binaries**)
        * [install_i2c_tools](users_files/install_deb_i2c_tools.sh) -- install utilities for 'i2c' (**binaries**)
        * [install_libc6dev](users_files/install_deb_libc6dev.sh) -- install development files of library 'libc6dev' (**binaries**)
        * [install_lsof](users_files/install_deb_lsof.sh) -- install utility 'lsof' (**binaries**)
        * [install_socat](users_files/install_deb_socat.sh) -- install utility 'socat' (**binaries**)
        * [install_xml2](users_files/install_deb_xml2.sh) --install library 'xml2' (**binaries**)

