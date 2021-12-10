#!/bin/bash
show_current_task

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

APPPATH="$1"
APPNAME="$2"
if [ -z "${APPNAME}" ] ; then APPNAME=$(basename "${APPPATH}") ; fi

if ! [ -d "${APPPATH}" ] ; then goto_exit 1 ; fi

if ! pushd "${CACHE}" ; then goto_exit 2 ; fi

    preAuthRoot && sudo rm -rf "${APPNAME}"
    preAuthRoot && sudo rm -rf "${SYSROOT}/opt/${APPNAME}"

    if ( cp -r "${APPPATH}" "${APPNAME}" ) ; then

        pushd "${APPNAME}"

            rm *.json
            rm moc_*.cpp
            rm qml_*.cpp
            rm *_qml.cpp
            rm Makefile
            rm *.o
            rm "${APPNAME}"
            
            if ( "${SYSROOT}/opt"/Qt*"/bin/qmake" CONFIG+=release) ; then

                #make clean

                transformFsToHost
                if make ; then
                    if ( preAuthRoot && sudo cp -r "${PWD}" "${SYSROOT}/opt/" ) ; then
                        transformFsToDevice
                        show_message "Qt APPLICATION ${APPNAME} WAS SUCCESSFULLY INSTALLED!"
                        exit 0
                    fi
                fi
            fi
        popd
    fi
popd

show_message "UNABLE TO INSTALL Qt APPLICATION ${APPNAME}!"
goto_exit 3
