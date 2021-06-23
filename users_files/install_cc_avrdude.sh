#!/bin/bash
show_current_task

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

exportdefvar avrdude_GITURL     "https://github.com/kcuzner"
exportdefvar avrdude_GITREPO    "avrdude"
exportdefvar avrdude_BRANCH     "master"
exportdefvar avrdude_REVISION   ""
exportdefvar avrdude_RECOMPILE  n

exportdefvar avrdude_LINUXGPIO  y

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --
# GET PACKAGES --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ----

if ! ( get_git_pkg "${avrdude_GITURL}" "${avrdude_GITREPO}" "${avrdude_BRANCH}" "${avrdude_REVISION}" ) ; then goto_exit 1 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --
# INSTALL PACKAGES - --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

if ! pushd "${CACHE}/${avrdude_GITREPO}-${avrdude_BRANCH}/avrdude" ; then goto_exit 2 ; fi

    if [ "${avrdude_RECOMPILE}" != "n" ] ; then
        rm ".compiled"
        rm -rf "bin"
        make clean
    fi

    if ! [ -f ".compiled" ] ; then

        if [ -d "bin" ] ; then rm -rf "bin"/*
        else mkdir "bin"
        fi
    
        transformFsToHost

        if ! ( ./bootstrap ) ; then goto_exit 3 ; fi

        if [ "${avrdude_LINUXGPIO}" == "y" ] ; then export ENABLE_LINUXGPIO="--enable-linuxgpio"
        else unset ENABLE_LINUXGPIO
        fi

        if ! ( ./configure --host=${ARCH}-linux --prefix="/" ${ENABLE_LINUXGPIO} ) ; then goto_exit 4 ; fi

        if ! ( make $NJ ) ; then goto_exit 5 ; fi

        if ! ( DESTDIR="bin" make install ) ; then goto_exit 6 ; fi

        transformFsToDevice

        echo "1" > ".compiled"
    fi

    if  ! (
        ( preAuthRoot && sudo cp -R "bin/bin"   "${SYSROOT}${HOST_PREFIX}"/ ) &&
        ( preAuthRoot && sudo cp -R "bin/etc"   "${SYSROOT}"/ ) &&
        ( preAuthRoot && sudo cp -R "bin/share" "${SYSROOT}${HOST_PREFIX}"/ )
    )
    then goto_exit 6 ; fi

popd

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

show_message "AVRDUDE WAS SUCCESSFULLY INSTALLED!"

