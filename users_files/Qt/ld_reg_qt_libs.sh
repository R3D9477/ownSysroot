#!/bin/bash

source "set_env.sh"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

preAuthRoot
echo "${Qt_DIR}/lib" | sudo tee "${SYSROOT}/etc/ld.so.conf.d/Qt${Qt_VER}.conf"

chroot_script "ldconfig"
