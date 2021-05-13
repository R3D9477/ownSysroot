# ownSysroot
System for sysroot building written on pure Bash.

### build_OpenRex_Full.sh:
* script for automated building of Debian-based sysroot for OprenRex board (based on i.mx6 SoC)
    * configs:
        * users_files/configure_autologin.sh - configure autologin (shell)
        * users_files/configure_disable_eth.sh - configure to disable ethernet (shell)
        * users_files/configure_systemd_bootsplash.sh - set a custom logo (shell)
    * i.mx6:
        * imx/install_imx_gpu.sh - install GPU support on i.mx6-based SoM (cross-compilation)
        * imx/install_imx_vpu_cc.sh - install VPU support on i.mx6 on i.mx6-based SoM (cross-compilation)
        * imx/install_imx_gst_cc.sh - install GStreamer 1.0 plugins with VPU/GPU acceleration on i.mx6-based SoM (cross-compilation)
    * multimedia:
        * users_files/install_ffmpeg.sh - install FFMpeg package (cross-compilation)
        * users_files/install_gstreamer-1.0.sh - install GStreamer 1.0 package (cross-compilation)
        * users_files/install_v4l2loopback.sh - install V4L2 loopback driver (cross-compilation)
        * users_files/install_x264.sh - install x264 libs (cross-compilation)
    * drivers:
        * users_files/install_rtl8188eu.sh - install Realtek drvier (cross-compilation)
    * services:
        * users_files/install_ftpserver.sh - install and configure FTP server with anonymous access (bin-pkg)
        * users_files/install_wifiap.sh - install WiFi Access point (bin-pkg, shell)
    * Qt:
        * users_files/install_Qt.sh - install Qt libs (cross-compilation)
            * Qt Core
            * Qt Quick2
            * Qt Multimedia
            * Qt SerialPort
        * users_files/install_QtApp.sh - install user's custom application (cross-compilation)
    * Other:
        * users_files/install_spi-test.sh - install application 'spitest' (cross-compilation)
        * users_files/install_avrdude.sh - install application 'avrdude' (cross-compilation)
        * users_files/install_fbsrc.sh - install application 'fbsrc' (cross-compilation)



