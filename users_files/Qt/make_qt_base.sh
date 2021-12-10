#!/bin/bash

source "set_env.sh"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

pushd "${CACHE}"
    
    if [ "${Qt_INSTALL_BASE}" == "y" ] ; then

        if ! mk_inst qtbase                                     \
            -${Qt_LICENSE} -confirm-license                     \
            -sysroot "${SYSROOT}"                               \
            -prefix  "${Qt_DIR}"                                \
            -opengl  "${Qt_OPENGL}"                             \
            -device  "${Qt_DEVICE}"                             \
            -device-option CROSS_COMPILE="${TOOLCHAIN_PREFIX}"  \
            -rpath                                              \
            -release                                            \
            -recheck                                            \
            -silent                                             \
            -qt-zlib                                            \
            -nomake tests                                       \
            -nomake examples                                    \
            -no-use-gold-linker                                 \
            -no-feature-getentropy                              \
        ; then
            goto_exit 1; fi
            
    fi

    preAuthRoot && sudo chmod -R +r "${SYSROOT}${Qt_DIR}"

popd

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

show_message "Qt ${Qt_VER} libs were successfully built"
