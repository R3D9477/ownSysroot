#!/bin/bash

exportdefvar avrdude_BRANCH     "master"
exportdefvar avrdude_RECOMPILE  "y"
exportdefvar avrdude_LINUXGPIO  "y"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# GET PACKAGES --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

avrdude_GITURL="https://github.com/kcuzner"
avrdude_GITREPO="avrdude"

if ! ( get_git_pkg "${avrdude_GITURL}" "${avrdude_GITREPO}" "${avrdude_BRANCH}" ) ; then goto_exit 1 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# INSTALL PACKAGES - --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

if ! pushd "${CACHE}/${avrdude_GITREPO}-${avrdude_BRANCH}/avrdude" ; then goto_exit 2 ; fi

    if [ "${avrdude_RECOMPILE}" != "n" ] ; then
        rm ".compiled"
        rm -rf "bin"
        make clean
    fi

    if [ -d "bin" ] ; then rm -rf "bin"/*
    else mkdir "bin"
    fi
    
    transformFsToHost

    if ! [ -f ".compiled" ] ; then

        if ! ( ./bootstrap ) ; then goto_exit 3 ; fi
    
        if [ "${avrdude_LINUXGPIO}" == "y" ] ; then export ENABLE_LINUXGPIO="--enable-linuxgpio"
        else unset ENABLE_LINUXGPIO
        fi
    
        if ! ( ./configure --host=${ARCH}-linux --prefix="/" ${ENABLE_LINUXGPIO} ) ; then goto_exit 4 ; fi

        if ! ( make $NJ ) ; then goto_exit 5 ; fi

        if ! ( DESTDIR="bin" make install ) ; then goto_exit 6 ; fi
        
        echo "1" > ".compiled"
    fi

    transformFsToDevice

    if  ! (
        ( preAuthRoot && sudo cp -R "bin/bin"   "${SYSROOT}${HOST_PREFIX}"/ ) &&
        ( preAuthRoot && sudo cp -R "bin/etc"   "${SYSROOT}"/ ) &&
        ( preAuthRoot && sudo cp -R "bin/share" "${SYSROOT}${HOST_PREFIX}"/ )
    )
    then goto_exit 6 ; fi
    
popd

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

show_message "AVRDUDE WAS SUCCESSFULLY INSTALLED!"

