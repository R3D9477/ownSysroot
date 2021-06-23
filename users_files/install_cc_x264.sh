#!/bin/bash
show_current_task

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

exportdefvar x264_GITURL     "https://code.videolan.org"
exportdefvar x264_GITREPO    "videolan"
exportdefvar x264_BRANCH     "stable"
exportdefvar x264_REVISION   ""
exportdefvar x264_RECOMPILE  n

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# GET PACKAGES --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if ! ( get_git_pkg "${x264_GITURL}" "${x264_GITREPO}" "${x264_BRANCH}" "${x264_REVISION}" ) ; then goto_exit 1 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# INSTALL PACKAGES - --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

if ! pushd "${CACHE}/${x264_GITREPO}-${x264_BRANCH}/x264" ; then goto_exit 2 ; fi

    if [ "${x264_RECOMPILE}" != "n" ] ; then
        rm ".compiled"
        rm -rf "bin"
        make clean
    fi

    transformFsToHost

    if ! [ -f ".compiled" ] ; then

        if ! ( ./configure                               \
            --arch=${ARCH}                               \
            --cpu=${mARCH}                               \
            --target-os=linux                            \
            --enable-static                              \
            --host=${ARCH}-linux                         \
            --disable-cli                                \
            --enable-pic                                 \
            --cross-prefix="${TOOLCHAIN_SYS}-"           \
            --sysroot="${SYSROOT}"                       \
            --prefix="${HOST_PREFIX}" ) ; then exit 4 ; fi

        if ! ( make $NJ ) ; then exit 5 ; fi

        echo "1" > ".compiled"
    fi

    transformFsToDevice

    if [ -d "bin" ] ; then rm -rf "bin"/*
    else mkdir "bin"
    fi

    if ! ( DESTDIR="bin" make install ) ; then exit 6 ; fi

    pushd "bin${HOST_PREFIX}/lib/pkgconfig"

        for PCFILE in *.pc ; do
            if [ -z "$(cat ${PCFILE} | grep /${TOOLCHAIN_SYS}/lib)" ] ; then
                sed -i "s|/lib|/${TOOLCHAIN_SYS}/lib|g" "${PCFILE}"
            fi
        done
    popd

    if  ! (
        ( preAuthRoot && sudo cp -R "bin${HOST_PREFIX}/include" "${SYSROOT}${HOST_PREFIX}/" ) &&
        ( preAuthRoot && sudo cp -R "bin${HOST_PREFIX}/lib"/*   "${SYSROOT}${HOST_PREFIX}${HOST_LIBDIR}/" )
    )
    then
        exit 7
    fi

popd

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

show_message "x264 WAS SUCCESSFULLY INSTALLED!"
