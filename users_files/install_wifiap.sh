#!/bin/bash

install_deb_pkgs iw hostapd isc-dhcp-server

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# SET WIFI-AP --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ----

if ! ( preAuthRoot && sudo install -p -m 755  "wifiap/wifiap-reset.sh" "${SYSROOT}/opt/" ) ; then goto_exit 1 ; fi
preAuthRoot && sudo chmod +x "${SYSROOT}/opt/wifiap-reset.sh"

if ! ( preAuthRoot && sudo install -p -m 755  "wifiap/wifiap-start.sh" "${SYSROOT}/opt/" ) ; then goto_exit 2 ; fi
preAuthRoot && sudo chmod +x "${SYSROOT}/opt/wifiap-start.sh"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

preAuthRoot && sudo chroot "${SYSROOT}" systemctl unmask    hostapd
preAuthRoot && sudo chroot "${SYSROOT}" systemctl disable   hostapd
preAuthRoot && sudo chroot "${SYSROOT}" systemctl unmask    isc-dhcp-server
preAuthRoot && sudo chroot "${SYSROOT}" systemctl disable   isc-dhcp-server
