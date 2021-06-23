#!/bin/bash

IMX_GSTREAMER_BRANCH="master"
IMX_GSTERANER_REVISION="889b8352ca09cd224be6a2f8d53efd59a38fa9cb" #

IMX_EGL="fb"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# GET PACKAGES --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

IMX_GIT_URL="https://github.com/Freescale"

DEV_SRC_DIR="/usr/src/imx/gst"
if ! ( preAuthRoot && sudo mkdir -p "${SYSROOT}${DEV_SRC_DIR}" ) ; then exit 1 ; fi

if ! ( get_git_pkg "${IMX_GIT_URL}" "gstreamer-imx" "${IMX_GSTREAMER_BRANCH}" "${IMX_GSTERANER_REVISION}" )     ; then exit 1 ; fi
if ! ( preAuthRoot && sudo cp -R "${CACHE}/gstreamer-imx-${IMX_GSTREAMER_BRANCH}" "${SYSROOT}${DEV_SRC_DIR}/" ) ; then exit 1 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# INSTALL PACKAGES - --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

transformFsToHost

pushd "${CACHE}/gstreamer-imx-${IMX_GSTREAMER_BRANCH}"

    rm -rf bin ; mkdir bin

    if [[ "${PWD}" =~ "v2" ]] ; then
        mkdir build
        pushd build
            if ! ( meson .. -Dprefix=${HOST_PREFIX} ) ; then exit 1 ; fi
            if ! ( DESTDIR=bin ninja install ) ; then exit 1 ; fi
        popd
    else
        export PKG_CONFIG_PATH="${SYSROOT}${HOST_PREFIX}${HOST_LIBDIR}/pkgconfig"
        export CFLAGS="${CFLAGS} -I${SYSROOT}${HOST_PREFIX}/include/imx-mm/audio-codec"
        export CFLAGS="${CFLAGS} -I${SYSROOT}${HOST_PREFIX}/include/gstreamer-1.0"
        export CFLAGS="${CFLAGS} -I${SYSROOT}${HOST_PREFIX}/include/glib-2.0"
        export CFLAGS="${CFLAGS} -I${SYSROOT}${HOST_PREFIX}${HOST_LIBDIR}/glib-2.0/include"

        if ! ( ./waf configure                                       \
                --prefix="${HOST_PREFIX}"                            \
                --kernel-headers="${SYSROOT}/include"                \
                --g2d-includes="${SYSROOT}${HOST_PREFIX}/include"    \
                --egl-platform="${IMX_EGL}"                          \
        ) ; then exit 2 ; fi

        if ! ( ./waf ) ; then exit 2 ; fi
        if ! ( ./waf install --destdir="bin" ) ; then exit 2 ; fi
    fi

    install_to_sysroot "bin"

    echo ""
    IMX_GST_PLUGINS=$(preAuthRoot && sudo chroot "${SYSROOT}" gst-inspect-1.0 | grep imx)
    echo "${IMX_GST_PLUGINS}"
    echo ""

    if [ -z "$(echo ${IMX_GST_PLUGINS} | grep imxv4l2)" ] ; then
        echo ''
        echo ' i.MX: V4L2 PLUGIN IS NOT FOUND'
        echo ''
        exit 1
    fi

    fix_chmod

popd

transformFsToDevice

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

echo ""
echo "    IMX GST WAS SUCCESSFULLY INSTALLED!"
echo ""

exit 0
