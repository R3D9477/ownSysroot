#!/bin/bash

exportdefvar gst_BRANCH     "1.16"
exportdefvar gst_RECOMPILE  y
exportdefvar gst_MESON_OPS  "-Dorc=disabled -Dgst-plugins-base:gio=disabled -Dgst-plugins-bad:opencv=disabled"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

show_current_task

show_message                                \
    "gst_BRANCH     : ${gst_BRANCH}"        \
    "gst_RECOMPILE  : ${gst_RECOMPILE}"     \
    "gst_MESON_OPS  : ${gst_MESON_OPS}"

show_message_counter "    continue in:"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --
# GET PACKAGES --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ----

GST_GIT_URL="https://gitlab.freedesktop.org/gstreamer"

if ! ( get_git_pkg "${GST_GIT_URL}" "gst-build" "${gst_BRANCH}" ) ; then goto_exit 1 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --
# INSTALL PACKAGES - --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

if ! pushd "${CACHE}/gst-build-${gst_BRANCH}" ; then goto_exit 2 ; fi

    install_deb_pkgs libc6-dev libmount-dev libglib2.0-dev

    transformFsToHost

    if ( [ "${gst_RECOMPILE}" != "n" ] || ! [ -f ".made" ] ) ; then
        rm ".made"
        rm -rf "bin"
        rm -rf "build"
    fi

    if ( ! [ -f ".made" ] || ! [ -d "bin" ] || ! [ -d "build" ] ) ; then

        rm ".made"

        mkdir "build"
        pushd "build"
            if ! ( meson ${gst_MESON_OPS} --cross-file="${MESON_INI_FILE}" --prefix="${HOST_PREFIX}" ".." ) ; then
                goto_exit 3
            fi
        popd

        if ( ! [ -f ".made" ] || ! [ -d "build" ] ) ; then
            rm ".made"
            mkdir "build"
            pushd "build"
                if ! ( ninja ) ; then goto_exit 4 ; fi
            popd
        fi

        if ! [ -f "${CACHE}/gst-build-${gst_BRANCH}.tar" ] ; then
            tar --exclude=".made" --exclude="bin" --exclude="build" -C ".." -cf "${CACHE}/gst-build-${gst_BRANCH}.tar" "gst-build-${gst_BRANCH}"
        fi

        echo "1" > ".made"
    fi

    if [ -f ".made" ] ; then

        mkdir  "bin"
        pushd  "build"
            if ! ( DESTDIR="${CACHE}/gst-build-${gst_BRANCH}/bin" ninja install ) ; then goto_exit 5 ; fi
        popd
    fi

    install_to_sysroot "bin"

    transformFsToDevice

    preAuthRoot && sudo rm -rf "${SYSROOT}${HOST_PREFIX}/lib/gstreamer-1.0"
    if ! ( preAuthRoot && sudo chroot "${SYSROOT}" ln -s "${HOST_PREFIX}${HOST_LIBDIR}/gstreamer-1.0" "${HOST_PREFIX}/lib/gstreamer-1.0" ) ; then goto_exit 6 ; fi

popd

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

show_message "GSTREAMER-1.0 WAS SUCCESSFULLY INSTALLED!"
