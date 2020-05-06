#!/bin/bash

if [ -z "${UBOOT_GITURL}" ]; then export UBOOT_URL="https://github.com/Freescale/u-boot-fslc.git" ; fi
if [ -z "${UBOOT_BRANCH}" ]; then export UBOOT_BRANCH="2018.09+fscl" ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if ! pushd "$CACHE" ; then exit 1 ; fi

    if ! [ -d "u-boot-${UBOOT_BRANCH}" ] ; then
        if [ -f "u-boot-${UBOOT_BRANCH}.tar" ]; then
            if ! ( tar -xf "u-boot-${UBOOT_BRANCH}.tar" ) ; then exit 2 ; fi
        else
            if git clone -b "${UBOOT_BRANCH}" --single-branch "${UBOOT_GITURL}" "u-boot-${UBOOT_BRANCH}" ; then
                tar -cf "u-boot-${UBOOT_BRANCH}.tar" "u-boot-${UBOOT_BRANCH}"
            else
                exit 2
            fi
        fi
    fi

    #--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    pushd "${USERDIR}"
        if ! [ -z "${UBOOT_PRECOMPILE}" ] ; then
            if ! ( eval ${UBOOT_PRECOMPILE} ) ; then exit 3 ; fi
        fi
    popd

    #--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if ! pushd "u-boot-${UBOOT_BRANCH}" ; then exit 4 ; fi

        if ( [ "${UBOOT_RECOMPILE}" == "y" ] || ( [ "${UBOOT_RECOMPILE}" == "a" ] && ( ! [ -f "SPL" ] && ! [ -f "u-boot.imx" ] && ! [ -f "u-boot.img" ] ) ) ) ; then

            if [ "${UBOOT_CLEAN}" == "y" ] ; then
                make clean
            fi

            if ! make ARCH=${ARCH} CROSS_COMPILE="${TOOLCHAIN_PREFIX}" ${NJ} ${UBOOT_CONFIG} ; then exit 5 ; fi
            if ! make ARCH=${ARCH} CROSS_COMPILE="${TOOLCHAIN_PREFIX}" ${NJ} ; then exit 6 ; fi
        fi
    popd

popd
