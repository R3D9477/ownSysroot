#!/bin/bash

if [ -z "${spitest_BRANCH}"    ] ; then export spitest_BRANCH="master"  ; fi
if [ -z "${spitest_RECOMPILE}" ] ; then export spitest_RECOMPILE="y"    ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# GET PACKAGES --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

spitest_GIT_URL="https://github.com/mwelling"

if ! ( get_git_pkg "${spitest_GIT_URL}" "spi-test" "${spitest_BRANCH}" ) ; then goto_exit 1 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# INSTALL PACKAGES - --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

if ! pushd "${CACHE}/spi-test-${spitest_BRANCH}" ; then goto_exit 2 ; fi

    if [ "${spitest_RECOMPILE}" != "n" ] ; then
        rm ".compiled"
        make clean
    fi

    transformFsToHost

    if ! [ -f ".compiled" ] ; then

        if ! ( make all ) ; then goto_exit 3 ; fi
        
        echo "1" > ".compiled"
    fi

    transformFsToDevice

    if  ! ( preAuthRoot && sudo cp "spi_test" "${SYSROOT}${HOST_PREFIX}/bin"/ ) then goto_exit 4 ; fi
    
popd

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

show_message "SPI-TEST WAS SUCCESSFULLY INSTALLED!"
