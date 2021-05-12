#!/bin/bash

source "set_env.sh"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

if ( [ "${Qt_RECOMPILE}" == "n" ] && [ "${Qt_INSTALL_BINBCK}" == "y" ] && [ -d "${Qt_BINBCK}" ] ) ; then

    if ( preAuthRoot && sudo cp -r "${Qt_BINBCK}" "${SYSROOT}${Qt_DIR}" ) ; then

        show_message "Qt ${Qt_VER} has been successfully installed to ${SYSROOT}${Qt_DIR}!"
        exit 0
    fi
fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

show_message "Unable to install Qt from ${Qt_BINBCK} to ${SYSROOT}${Qt_DIR}!"
goto_exit 1
