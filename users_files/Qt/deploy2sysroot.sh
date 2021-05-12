#!/bin/bash

source "set_env.sh"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if ( [ -d "${Qt_EXPORT}" ] && [ -d "${SYSROOT}${Qt_DIR}" ] ) ; then

    if ( preAuthRoot && sudo cp -r "${Qt_EXPORT}" "${SYSROOT}${Qt_DIR}" ) ; then

        if ( preAuthRoot && sudo chmod -R +rx "${SYSROOT}${Qt_DIR}/$(basename ${Qt_EXPORT})" ) ; then

            show_message "Qt ${Qt_VER} test apps were deployed to ${Qt_EXPORT}"
            exit 0
        fi
    fi
fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

show_message "UNABLE TO DEPLOY TEST APPS TO ${SYSROOT}${Qt_DIR}"
goto_exit 1
