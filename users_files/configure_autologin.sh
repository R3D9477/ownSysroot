#!/bin/bash
show_current_task

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

# AUTOLOGIN TO ROOT

preAuthRoot && sudo sed -i 's#ExecStart=-/sbin/agetty.*#ExecStart=-/sbin/agetty --noclear -a root %I $TERM#g' "${SYSROOT}/lib/systemd/system/getty@.service"
