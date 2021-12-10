#!/bin/bash
show_current_task

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

exportdefvar gst_GITURL     "https://gitlab.freedesktop.org/gstreamer"
exportdefvar gst_GITREPO    "gst-build"
exportdefvar gst_BRANCH     "1.18"
exportdefvar gst_REVISION   ""
exportdefvar gst_PATCH      ""
exportdefvar gst_RECOMPILE  n

exportdefvar gst_MESON_OPS  ""

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

show_message                                \
    "gst_BRANCH     : ${gst_BRANCH}"        \
    "gst_RECOMPILE  : ${gst_RECOMPILE}"     \
    "gst_MESON_OPS  : ${gst_MESON_OPS}"

show_message_counter "    continue in:"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --
# GET PACKAGES --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ----

if ! ( get_git_pkg "${gst_GITURL}" "${gst_GITREPO}" "${gst_BRANCH}" "${gst_REVISION}" ) ; then goto_exit 1 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --
# INSTALL PACKAGES - --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

if ! pushd "${CACHE}/${gst_GITREPO}-${gst_BRANCH}" ; then goto_exit 2 ; fi

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

        if ! ( run_patcher "${gst_PATCH}" ) ; then goto_exit 4  ; fi
        
        if ( ! [ -f ".made" ] || ! [ -d "build" ] ) ; then
            rm ".made"
            mkdir "build"
            pushd "build"
                if ! ( ninja ) ; then goto_exit 5 ; fi
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
            if ! ( DESTDIR="${CACHE}/gst-build-${gst_BRANCH}/bin" ninja install ) ; then goto_exit 6 ; fi
        popd
    fi

    install_to_sysroot "bin"

    transformFsToDevice

    preAuthRoot && sudo rm -rf "${SYSROOT}${HOST_PREFIX}/lib/gstreamer-1.0"
    if ! ( preAuthRoot && sudo chroot "${SYSROOT}" ln -s "${HOST_PREFIX}${HOST_LIBDIR}/gstreamer-1.0" "${HOST_PREFIX}/lib/gstreamer-1.0" ) ; then goto_exit 7 ; fi

    preAuthRoot
    sudo mkdir -p "${SYSROOT}/profile.d"
    echo "#!/bin/sh
export GST_PLUGIN_SCANNER='/usr/lib/gstreamer-1.0'
export GST_PLUGIN_SYSTEM_PATH=${GST_PLUGIN_SCANNER}" | sudo tee "${SYSROOT}/profile.d/gst_env.sh"
    sudo chmod +x "${SYSROOT}/profile.d/gst_env.sh"

popd

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

show_message "GSTREAMER-1.0 WAS SUCCESSFULLY INSTALLED!"
