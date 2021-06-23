#!/bin/bash
show_current_task

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

exportdefvar spitest_GITURL     "https://github.com/mwelling"
exportdefvar spitest_GITREPO    "spi-test"
exportdefvar spitest_BRANCH     "master"
exportdefvar spitest_REVISION   ""
exportdefvar spitest_RECOMPILE  n

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# GET PACKAGES --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if ! ( get_git_pkg "${spitest_GITURL}" "${spitest_GITREPO}" "${spitest_BRANCH}" "${spitest_REVISION}" ) ; then goto_exit 1 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# INSTALL PACKAGES - --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

if ! pushd "${CACHE}/${spitest_GITREPO}-${spitest_BRANCH}" ; then goto_exit 2 ; fi

    if [ "${spitest_RECOMPILE}" != "n" ] ; then
        rm ".compiled"
        rm -rf "bin"
        make clean
    fi

    if ! [ -f ".compiled" ] ; then

        transformFsToHost
    
        if ! ( make all ) ; then goto_exit 3 ; fi
    
        transformFsToDevice
    
        echo "1" > ".compiled"
    fi

    if  ! ( preAuthRoot && sudo cp "spi_test" "${SYSROOT}${HOST_PREFIX}/bin"/ ) then goto_exit 4 ; fi
    
popd

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

show_message "SPI-TEST WAS SUCCESSFULLY INSTALLED!"
