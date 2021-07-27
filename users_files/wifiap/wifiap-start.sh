#!/bin/bash

systemctl stop hostapd
if [ -f "/var/run/hostapd.pid" ] ; then rm "/var/run/hostapd.pid" ; fi

systemctl stop isc-dhcp-server
if [ -f "/var/run/dhcpd.pid" ] ; then rm "/var/run/dhcpd.pid" ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

AP=$(iw dev | grep Interface | xargs | cut -f 2 -d " ")

if [ -z "$AP" ] ; then exit 1 ; fi
if [ -f "/var/run/wifiap_${AP}.pid" ] ; then exit 0 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

cat > "/etc/network/interfaces.d/99-wifiap_${AP}" << EOF
auto    ${AP}
iface   ${AP} inet static
address 10.0.0.1
netmask 255.255.255.0
EOF

cat > "/etc/sysctl.d/00_wifiap_${AP}_ipv6_off.conf" << EOF
net.ipv6.conf.${AP}.disable_ipv6=1
EOF

cat > "/etc/hostapd.conf" << EOF
interface=${AP}
driver=nl80211
ssid=MCP1
hw_mode=g
channel=6
wpa=0
EOF

cat > "/etc/default/hostapd" << EOF
DAEMON_CONF="/etc/hostapd.conf"
RUN_DAEMON="yes"
EOF

cat > "/etc/dhcp/dhcpd.conf" << EOF
subnet 10.0.0.0 netmask 255.255.255.224 {
    range 10.0.0.2 10.0.0.10;
    option routers 10.0.0.1;
    option subnet-mask 255.255.255.0;
    option broadcast-address 10.0.0.255;
    default-lease-time 600;
    max-lease-time 7200;
}
EOF

cat > "/etc/default/isc-dhcp-server" << EOF
INTERFACESv4=${AP}
EOF

cp -n "/etc/hosts" "/etc/hosts.bck"
sed -i "s|[0-9].*$(cat /etc/hostname)||g" "/etc/hosts"
echo "10.0.0.1 $(cat /etc/hostname)" | tee -a "/etc/hosts"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

systemctl unmask    ifupdown-pre
systemctl unmask    networking
systemctl restart   networking

systemctl start     hostapd
systemctl start     isc-dhcp-server

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

echo "1" > "/var/run/wifiap_${AP}.pid"
