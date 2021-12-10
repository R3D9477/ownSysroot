#!/bin/bash
show_current_task

exportdefvar IMX_GSTREAMER_BRANCH       "master" #"0.13.1"
exportdefvar IMX_GSTERANER_REVISION     "889b8352ca09cd224be6a2f8d53efd59a38fa9cb" #""

exportdefvar IMX_EGL                    "fb"

exportdefvar IMX_GIT_URL                "https://github.com/Freescale"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# GET PACKAGES --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if ! ( get_git_pkg "${IMX_GIT_URL}" "gstreamer-imx" "${IMX_GSTREAMER_BRANCH}" "${IMX_GSTERANER_REVISION}" )     ; then goto_exit 1 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# INSTALL PACKAGES - --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

transformFsToHost

pushd "${CACHE}/gstreamer-imx-${IMX_GSTREAMER_BRANCH}"

    rm -rf bin ; mkdir bin

    if [[ "${PWD}" =~ "v2" ]] ; then
        mkdir build
        pushd build
            if ! ( meson .. -Dprefix=${HOST_PREFIX} ) ; then goto_exit 1 ; fi
            if ! ( DESTDIR=bin ninja install ) ; then goto_exit 1 ; fi
        popd
    else
        export PKG_CONFIG_PATH="${SYSROOT}${HOST_PREFIX}${HOST_LIBDIR}/pkgconfig"
        export CFLAGS="${CFLAGS} -I${SYSROOT}${HOST_PREFIX}/include/imx-mm/audio-codec"
        export CFLAGS="${CFLAGS} -I${SYSROOT}${HOST_PREFIX}/include/gstreamer-1.0"
        export CFLAGS="${CFLAGS} -I${SYSROOT}${HOST_PREFIX}/include/glib-2.0"
        export CFLAGS="${CFLAGS} -I${SYSROOT}${HOST_PREFIX}${HOST_LIBDIR}/glib-2.0/include"

        if [ -f ./waf ] ; then
        
            if ! ( ./waf configure                                       \
                    --prefix="${HOST_PREFIX}"                            \
                    --kernel-headers="${SYSROOT}/include"                \
                    --g2d-includes="${SYSROOT}${HOST_PREFIX}/include"    \
                    --egl-platform="${IMX_EGL}"                          \
            ) ; then goto_exit 2 ; fi

            if ! ( ./waf ) ; then goto_exit 2 ; fi
            if ! ( ./waf install --destdir="bin" ) ; then goto_exit 2 ; fi
            
        else
        
            rm -rf "build"
            mkdir  "build"
            pushd  "build"
                if ! ( meson ${gst_MESON_OPS} --cross-file="${MESON_INI_FILE}" --prefix="${HOST_PREFIX}" ".." )
                then goto_exit 3
                fi
                mkdir "bin"
                if ! ( DESTDIR="${CACHE}/gstreamer-imx-${IMX_GSTREAMER_BRANCH}/bin" ninja install )
                then goto_exit 4
                fi
            popd
            
        fi
    fi

    install_to_sysroot "bin"

    echo ""
    IMX_GST_PLUGINS=$(preAuthRoot && sudo chroot "${SYSROOT}" gst-inspect-1.0 | grep imx)
    echo "${IMX_GST_PLUGINS}"
    echo ""

    if [ -z "$(echo ${IMX_GST_PLUGINS} | grep imxv4l2)" ] ; then
        show_message "i.MX: V4L2 PLUGIN IS NOT FOUND"
        goto_exit 4
    fi

    fix_chmod

popd

transformFsToDevice

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

show_message "IMX GST WAS SUCCESSFULLY INSTALLED!"
