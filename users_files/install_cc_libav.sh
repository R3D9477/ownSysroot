#!/bin/bash
show_current_task

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

exportdefvar libav_GITURL      "https://github.com/libav"
exportdefvar libav_GITREPO     "libav"
exportdefvar libav_BRANCH      "release/12"
exportdefvar libav_REVISION    ""
exportdefvar libav_RECOMPILE   n

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

show_message                                    \
    "libav_BRANCH       : ${libav_BRANCH}"      \
    "libav_RECOMPILE    : ${libav_RECOMPILE}"   \
    "libav_EXTRAARGS    : ${libav_EXTRAARGS}"   \
    "ARCH               : ${ARCH}"              \
    "CPU                : ${mARCH}"             \
    "PATH               : ${PATH}"              \
    "TOOLCHAIN_SYS      : ${TOOLCHAIN_SYS}"     \
    "PREFIX             : ${HOST_PREFIX}"       \
    "SYSROOT            : ${SYSROOT}"

show_message_counter "    continue in:"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --
# GET PACKAGES --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ----

if ! ( get_git_pkg "${libav_GITURL}" "${libav_GITREPO}" "${libav_BRANCH}" "${libav_REVISION}" ) ; then goto_exit 1 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --
# INSTALL PACKAGES - --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

if ! pushd "${CACHE}/${libav_GITREPO}-${libav_BRANCH}" ; then goto_exit 2 ; fi

    transformFsToHost

    if ( [ "${libav_RECOMPILE}" != "n" ] || ! [ -f ".made" ] ) ; then
        rm ".made"
        rm -rf "bin"
        make clean
    fi

    if ! [ -f ".made" ] ; then
    
        if ! ( ./configure                      \
            --arch=${ARCH}                      \
            --cpu=${mARCH}                      \
            --target-os=linux                   \
            --enable-cross-compile              \
            --cross-prefix="${TOOLCHAIN_SYS}-"  \
            --prefix="${HOST_PREFIX}"           \
            --sysroot="${SYSROOT}"              \
            --disable-outdev=oss                \
            --disable-indev=oss                 \
            --enable-shared                     \
            --enable-pic                        \
            ${libav_EXTRAARGS}
        )
        then goto_exit 3 ; fi

        if ! ( make ${NJ} ) ; then goto_exit 4 ; fi

        mkdir -p "bin/usr/lib"
        mkdir -p "bin/usr/bin"
        if ! ( DESTDIR=$(realpath "bin") make install ) ; then goto_exit 5 ; fi

        echo "1" > ".made"
    fi

    transformFsToDevice

    pushd "bin${HOST_PREFIX}/lib/pkgconfig"
        for PCFILE in *.pc ; do
            if [ -z "$(cat ${PCFILE} | grep ${HOST_LIBDIR})" ] ; then
                sed -i "s|/lib|${HOST_LIBDIR}|g" "${PCFILE}"
            fi
        done
    popd

    if  ! (
        ( preAuthRoot && sudo cp -R "bin${HOST_PREFIX}/bin"     "${SYSROOT}${HOST_PREFIX}/" ) &&
        ( preAuthRoot && sudo cp -R "bin${HOST_PREFIX}/share"   "${SYSROOT}${HOST_PREFIX}/" ) &&
        ( preAuthRoot && sudo cp -R "bin${HOST_PREFIX}/include" "${SYSROOT}${HOST_PREFIX}/" ) &&
        ( preAuthRoot && sudo cp -R "bin${HOST_PREFIX}/lib"/*   "${SYSROOT}${HOST_PREFIX}${HOST_LIBDIR}/" )
    )
    then goto_exit 6 ; fi

popd

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

show_message "LIBAV WAS SUCCESSFULLY INSTALLED!"
