#!/bin/bash
show_current_task

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# INSTALL PATCHES -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

pushd "${CACHE}"

    if ( [ "${Qt_DEVICE}" == "imx6" ] || [ "${Qt_DEVICE}" == "linux-imx6-g++" ] ) ; then
        imx6_MKS_DIR="qtbase-${Qt_VER}/mkspecs/devices/linux-imx6-g++"
        if ! [ -f "${imx6_MKS_DIR}/imx6-qmake.conf" ] ; then
            show_message "FIX: imx6_qmake.conf"
            mv "${imx6_MKS_DIR}/qmake.conf" "${imx6_MKS_DIR}/imx6-qmake.conf"
            echo "include(imx6-qmake.conf)" > "${imx6_MKS_DIR}/qmake.conf"
            echo "QMAKE_RPATHDIR += ${SYSROOT}/lib/arm-linux-gnueabihf"     >> "${imx6_MKS_DIR}/qmake.conf"
            echo "QMAKE_RPATHDIR += ${SYSROOT}/usr/lib/arm-linux-gnueabihf" >> "${imx6_MKS_DIR}/qmake.conf"
        fi
    fi

    #patch -N -t -d "${CACHE}/qtmultimedia-${Qt_VER}" -p0 -i "${CACHE}/${IMX_PATCH_FILE_NAME}/QtMultimedia${Qt_VER}_imx.patch"

popd

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

exit 0
