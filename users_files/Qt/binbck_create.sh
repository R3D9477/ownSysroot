#!/bin/bash

source "set_env.sh"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

if [ "${Qt_MAKE_BINBCK}" != "y" ] ; then exit 0 ; fi

rm -rf "${Qt_BINBCK}"

if ( preAuthRoot && sudo chmod -R +rx "${SYSROOT}${Qt_DIR}" ) ; then

    if ! ( cp -r "${SYSROOT}${Qt_DIR}" "${Qt_BINBCK}" ) ; then

        show_message "UNABLE TO CREATE Qt ${Qt_VER} SDK"
        goto_exit 1
    fi
fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

show_message "Qt ${Qt_VER} SDK was placed to ${Qt_BINBCK}"
