#!/bin/bash

source "set_env.sh"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

function qbuild() {

    OPWD="${PWD}"

    if ! pushd "$1"; then exit 1 ; fi

        if ( "${SYSROOT}${Qt_DIR}/bin/qmake" CONFIG+=release ) ; then

            make clean

            if make ; then
                popd
                return 0
            fi
        fi
    popd

    show_message "UNABLE TO BUILD $1"
    return 1
}

function export_app() {

    APPDIR=${Qt_DIR}/$(basename "${Qt_EXPORT}")

    if rsync -a -r "${Qt_TEST}/$1/$1" "${Qt_EXPORT}/" ; then
        if rsync -a -r "${Qt_TEST}/launcher.sh" "${Qt_EXPORT}/$1.sh" ; then
            return 0
        fi
    fi

    show_message "UNABLE TO EXPORT $1"
    return 1
}

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if ! [ -d "${Qt_EXPORT}" ] ; then mkdir -p "${Qt_EXPORT}" ; fi

if ! ( qbuild "${Qt_TEST}/qt_c" )   ; then goto_exit 1 ; fi
if ! ( qbuild "${Qt_TEST}/qt_w" )   ; then goto_exit 2 ; fi
if ! ( qbuild "${Qt_TEST}/qt_qc" )  ; then goto_exit 3 ; fi

if ! ( export_app "qt_c" )          ; then goto_exit 4 ; fi
if ! ( export_app "qt_w" )          ; then goto_exit 5 ; fi
if ! ( export_app "qt_qc" )         ; then goto_exit 6 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

show_message "Qt $Qt_VER test apps were exported to $Qt_EXPORT"
