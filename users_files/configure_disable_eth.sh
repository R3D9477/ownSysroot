#!/bin/bash
show_current_task

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

# REMOVE ETH0

preAuthRoot
sudo rm "${SYSROOT}"/etc/network/interfaces.d/*eth*

exit 0
