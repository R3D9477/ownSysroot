#!/bin/bash

exportdefvar ffmpeg_GITURL      "https://git.ffmpeg.org"
exportdefvar ffmpeg_BRANCH      "release/4.2"
exportdefvar ffmpeg_RECOMPILE   n
exportdefvar ffmpeg_EXTRAARGS   " --extra-libs=-ldl --enable-libx264 --enable-nonfree --enable-gpl "

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

show_current_task

show_message                                    \
    "ffmpeg_BRANCH      : ${ffmpeg_BRANCH}"     \
    "ffmpeg_RECOMPILE   : ${ffmpeg_RECOMPILE}"  \
    "ffmpeg_EXTRAARGS   : ${ffmpeg_EXTRAARGS}"  \
    "ARCH               : ${ARCH}"              \
    "CPU                : ${mARCH}"             \
    "PATH               : ${PATH}"              \
    "TOOLCHAIN_SYS      : ${TOOLCHAIN_SYS}"     \
    "PREFIX             : ${HOST_PREFIX}"       \
    "SYSROOT            : ${SYSROOT}"

show_message_counter "    continue in:"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --
# GET PACKAGES --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ----

if ! ( get_git_pkg "${ffmpeg_GITURL}" "ffmpeg" "${ffmpeg_BRANCH}" ) ; then goto_exit 1 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --
# INSTALL PACKAGES - --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

if ! pushd "${CACHE}/ffmpeg-${ffmpeg_BRANCH}" ; then goto_exit 2 ; fi

    transformFsToHost

    if ( [ "${ffmpeg_RECOMPILE}" != "n" ] || ! [ -f ".made" ] ) ; then
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
            ${ffmpeg_EXTRAARGS}
        )
        then goto_exit 3 ; fi

        if ! ( make ${NJ} ) ; then goto_exit 4 ; fi

        mkdir "bin"
        if ! ( DESTDIR="bin" make install ) ; then goto_exit 5 ; fi

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

show_message "FFMPEG WAS SUCCESSFULLY INSTALLED!"
