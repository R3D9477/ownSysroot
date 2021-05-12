# imx6deb
Debian-based sysroot for imx6

## build_OpenRex_Full.sh:
* script for automated building of Debian-based sysroot for OprenRex board (based on i.mx6 SoC)
    * configs:
        * users_files/configure_autologin.sh - configure autologin
        * users_files/configure_disable_eth.sh - configure to disable ethernet
        * users_files/configure_systemd_bootsplash.sh - set a custom logo (system-based method)
    * i.mx6:
        * imx/install_imx_gpu.sh - install (crosscompile) GPU support on i.mx6-based SoM
        * imx/install_imx_vpu_cc.sh - install (crosscompile) VPU support on i.mx6 on i.mx6-based SoM
        * imx/install_imx_gst_cc.sh - install (crosscompile) GStreamer 1.0 plugins with VPU/GPU acceleration on i.mx6-based SoM
    * multimedia:
        * users_files/install_ffmpeg.sh - install FFMpeg package
        * users_files/install_gstreamer-1.0.sh - install GStreamer 1.0 package
        * users_files/install_v4l2loopback.sh - install V4L2 loopback driver
        * users_files/install_x264.sh - install x264 libs
    * services:
        * users_files/install_ftpserver.sh - install and configure FTP server with anonymous access
        * users_files/install_wifiap.sh - install WiFi Access point
        * users_files/install_rtl8188eu.sh - install Realtek drvier
    * Qt:
        * users_files/install_Qt.sh - install Qt libs
            * Qt Core
            * Qt Quick2
            * Qt Multimedia
            * Qt SerialPort
        * users_files/install_QtApp.sh - install user's custom application
    * Other:
        * users_files/install_spi-test.sh - install application 'spitest'
        * users_files/install_avrdude.sh - install application 'avrdude'
        * users_files/install_fbsrc.sh - install application 'fbsrc'



