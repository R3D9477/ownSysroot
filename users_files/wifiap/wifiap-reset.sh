#!/bin/bash

AP=$(iw dev | grep Interface | xargs | cut -f 2 -d " ")

systemctl stop hostapd
systemctl stop isc-dhcp-server

if [ -f "/etc/hosts.bck" ] ; then
    rm "/etc/hosts"
    mv "/etc/hosts.bck" "/etc/hosts"
fi

function rm_f() { if [ -f "$1" ] ; then rm -f "$1" ; fi }

rm_f "/etc/sysctl.d/00_wifiap_${AP}_ipv6_off.conf"
rm_f "/etc/network/interfaces.d/99-wifiap_${AP}"
rm_f "/etc/default/isc-dhcp-server"
rm_f "/etc/default/hostapd"
rm_f "/etc/dhcp/dhcpd.conf"
rm_f "/var/run/hostapd.pid"
rm_f "/var/run/dhcpd.pid"
rm_f "/var/run/wifiap_${AP}.pid"
