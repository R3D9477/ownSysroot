#!/bin/bash

source "set_env.sh"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

pushd "${CACHE}"

    if [ "${Qt_INSTALL_QML}" == "y" ] ; then
        if ! mk_inst qtdeclarative ; then goto_exit 2; fi
        if ! mk_inst qtquickcontrols2 ; then goto_exit 3; fi
    fi

    preAuthRoot && sudo chmod -R +r "${SYSROOT}${Qt_DIR}"

popd

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

show_message "Qt ${Qt_VER} libs were successfully built"
