#!/bin/bash
show_current_task

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

install_deb_pkgs proftpd

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --
# SET FTP-SERVER --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

preAuthRoot && sudo mkdir -p "${SYSROOT}/etc/proftpd/conf.d"
preAuthRoot && sudo mkdir -p "${SYSROOT}/var/ftp"
preAuthRoot && sudo chroot   "${SYSROOT}" chmod 777 "/var/ftp"

preAuthRoot && echo "<Anonymous /var/ftp/>
     User ftp
     Group ftp
     RequireValidShell no
     UserAlias anonymous ftp
     WtmpLog off
     <Directory *>
        <Limit WRITE>
           AllowAll
        </Limit>
     </Directory>
</Anonymous>" | sudo tee "${SYSROOT}/etc/proftpd/conf.d/anon.conf"

preAuthRoot && sudo sed -i "s|UseIPv6.*on|UseIPv6 off|g" "${SYSROOT}/etc/proftpd/proftpd.conf"
preAuthRoot && sudo sed -i "s|ServerName*.\"Debian\"|ServerName \"${DEV_HOSTNAME}\"|g" "${SYSROOT}/etc/proftpd/proftpd.conf"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

preAuthRoot && sudo chroot "${SYSROOT}" systemctl unmask    proftpd
preAuthRoot && sudo chroot "${SYSROOT}" systemctl disable   proftpd
