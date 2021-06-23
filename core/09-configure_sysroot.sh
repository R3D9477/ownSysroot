#!/bin/bash
show_current_task

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

preAuthRoot && echo "en_US UTF-8" | sudo tee "${SYSROOT}/etc/locale.gen"
preAuthRoot && sudo chroot "${SYSROOT}" locale-gen

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

preAuthRoot && echo "${DEV_HOSTNAME}" | sudo tee "${SYSROOT}/etc/hostname"

if ! [[ `cat "${SYSROOT}/etc/hosts" | grep ${DEV_HOSTNAME}` ]] ; then
    preAuthRoot && echo "127.0.1.1       ${DEV_HOSTNAME}" | sudo tee -a "${SYSROOT}/etc/hosts"
fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

preAuthRoot && sudo mkdir -p "${SYSROOT}/etc/network/interfaces.d"
preAuthRoot && echo "source /etc/network/interfaces.d/*" | sudo tee "${SYSROOT}/etc/network/interfaces"

preAuthRoot && echo "auto lo
iface lo inet loopback" | sudo tee "${SYSROOT}/etc/network/interfaces.d/00-lo"

preAuthRoot && echo "auto eth0
iface eth0 inet dhcp" | sudo tee "${SYSROOT}/etc/network/interfaces.d/01-eth0"

preAuthRoot && sudo mkdir -p "${SYSROOT}/etc/sysctl.d/"
preAuthRoot && echo "net.ipv6.conf.eth0.disable_ipv6=1" | sudo tee "${SYSROOT}/etc/sysctl.d/00_eth0_ipv6_off.conf"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

preAuthRoot && echo 'ACTIVE_CONSOLES="/dev/tty[1]"' | sudo tee    "${SYSROOT}/etc/default/console-setup"
preAuthRoot && echo 'CHARMAP="UTF-8"'               | sudo tee -a "${SYSROOT}/etc/default/console-setup"
preAuthRoot && echo 'CODESET="guess"'               | sudo tee -a "${SYSROOT}/etc/default/console-setup"
preAuthRoot && echo 'FONTFACE="Fixed"'              | sudo tee -a "${SYSROOT}/etc/default/console-setup"
preAuthRoot && echo 'FONTSIZE="8x16"'               | sudo tee -a "${SYSROOT}/etc/default/console-setup"
preAuthRoot && echo 'VIDEOMODE='                    | sudo tee -a "${SYSROOT}/etc/default/console-setup"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

preAuthRoot && sudo chroot "${SYSROOT}" bash -c "echo -e \"${DEV_PASS}\n${DEV_PASS}\" | passwd root"
