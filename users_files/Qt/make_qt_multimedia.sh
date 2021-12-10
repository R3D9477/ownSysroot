#!/bin/bash

source "set_env.sh"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

pushd "${CACHE}"
    
    if [ "${Qt_INSTALL_MM}" == "y" ] ; then
        if ! mk_inst qtmultimedia ; then goto_exit 4; fi
    fi

    preAuthRoot && sudo chmod -R +r "${SYSROOT}${Qt_DIR}"

popd

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

show_message "Qt ${Qt_VER} libs were successfully built"
