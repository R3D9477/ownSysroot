#!/bin/bash

preAuthRoot && echo "${DEV_HOSTNAME}" | sudo tee "${SYSROOT}/etc/hostname"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

preAuthRoot && sudo mkdir -p "${SYSROOT}/etc/network/interfaces.d"
preAuthRoot && echo "source /etc/network/interfaces.d/*" | sudo tee "${SYSROOT}/etc/network/interfaces"

preAuthRoot && echo "auto lo
iface lo inet loopback" | sudo tee "${SYSROOT}/etc/network/interfaces.d/00-lo"

preAuthRoot && echo "auto eth0
iface eth0 inet dhcp" | sudo tee "${SYSROOT}/etc/network/interfaces.d/01-eth0"

preAuthRoot && sudo mkdir -p "${SYSROOT}/etc/sysctl.d/"
preAuthRoot && echo "net.ipv6.conf.eth0.disable_ipv6=1" | sudo tee "${SYSROOT}/etc/sysctl.d/00_eth0_ipv6_off.conf"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

preAuthRoot && echo 'ACTIVE_CONSOLES="/dev/tty[1]"' | sudo tee    "${SYSROOT}/etc/default/console-setup"
preAuthRoot && echo 'CHARMAP="UTF-8"'               | sudo tee -a "${SYSROOT}/etc/default/console-setup"
preAuthRoot && echo 'CODESET="guess"'               | sudo tee -a "${SYSROOT}/etc/default/console-setup"
preAuthRoot && echo 'FONTFACE="Fixed"'              | sudo tee -a "${SYSROOT}/etc/default/console-setup"
preAuthRoot && echo 'FONTSIZE="8x16"'               | sudo tee -a "${SYSROOT}/etc/default/console-setup"
preAuthRoot && echo 'VIDEOMODE='                    | sudo tee -a "${SYSROOT}/etc/default/console-setup"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

echo 'LANG="en_US.UTF-8"
LANGUAGE="en_US:en"' | sudo tee "${SYSROOT}/etc/default/locale"

preAuthRoot && sudo chroot "${SYSROOT}" locale-gen en_US.UTF-8

preAuthRoot && sudo chroot "${SYSROOT}" bash -c "echo -e \"${DEV_PASS}\n${DEV_PASS}\" | passwd root"
