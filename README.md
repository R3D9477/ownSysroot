# ownSysroot
System for sysroot building written on pure Bash.

### build_OpenRex_Full.sh:
* script for automated building of Debian-based sysroot for OprenRex board (based on i.mx6 SoC)
    * configs:
        * [configure_autologin](users_files/configure_autologin.sh) - configure autologin (**shell**)
        * [configure_disable_eth](users_files/configure_disable_eth.sh) - configure to disable ethernet (**shell**)
        * [configure_systemd_bootsplash](users_files/configure_systemd_bootsplash.sh) - set a custom logo (**shell**)
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
        * [install_Qt](users_files/install_cc_Qt.sh) - install Qt libs (**cross-compilation**)
            * [Qt Core](https://github.com/R3D9477/ownSysroot/blob/master/users_files/Qt/make.sh#L81)
            * [Qt Quick2](https://github.com/R3D9477/ownSysroot/blob/master/users_files/Qt/make.sh#L97)
            * [Qt Multimedia](https://github.com/R3D9477/ownSysroot/blob/master/users_files/Qt/make.sh#L102)
            * [Qt SerialPort](https://github.com/R3D9477/ownSysroot/blob/master/users_files/Qt/make.sh#L106)
        * [install_QtApp](users_files/install_cc_QtApp.sh) - install user's custom application (**cross-compilation**)
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

