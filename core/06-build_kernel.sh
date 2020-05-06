#!/bin/bash

if [ -z "${KERNEL_GITURL}" ]; then export KERNEL_URL="https://github.com/Freescale/u-boot-fslc.git" ; fi
if [ -z "${KERNEL_BRANCH}" ]; then export KERNEL_BRANCH="4.1-2.0.x-imx-rex" ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if ! pushd "$CACHE" ; then exit 1 ; fi

    if ! [ -d "linux-${KERNEL_BRANCH}" ] ; then
        if [ -f "linux-${KERNEL_BRANCH}.tar" ]; then
            if ! ( tar -xf "linux-${KERNEL_BRANCH}.tar" ) ; then exit 2 ; fi
        else
            if git clone -b "${KERNEL_BRANCH}" --single-branch "https://github.com/voipac/linux-fslc.git" "linux-${KERNEL_BRANCH}" ; then
                tar -cf "linux-${KERNEL_BRANCH}.tar" "linux-${KERNEL_BRANCH}"
            else
                exit 2
            fi
        fi
    fi

    #--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    pushd "${USERDIR}"
        if ! [ -z "${KERNEL_PRECOMPILE}" ] ; then
            if ! ( eval ${KERNEL_PRECOMPILE} ) ; then exit 3 ; fi
        fi
    popd

    #--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if ! pushd "linux-${KERNEL_BRANCH}" ; then exit 4 ; fi

        #cp  "arch/arm/configs/${KERNEL_CONFIG}" ".config"
        #if ! ( make ARCH=${ARCH} CROSS_COMPILE="${TOOLCHAIN_PREFIX}" ${NJ} menuconfig ) ; then exit 5 ; fi

        if ( [ "${KERNEL_RECOMPILE}" == "y" ] || ( [ "${KERNEL_RECOMPILE}" == "a" ] && ! [ -f "vmlinux" ] ) ) ; then

            if [ "${KERNEL_CLEAN}" == "y" ] ; then
                make clean
            fi

            if ! ( make ARCH=${ARCH} CROSS_COMPILE="${TOOLCHAIN_PREFIX}" ${NJ} ${KERNEL_CONFIG} ) ; then exit 5 ; fi
            if ! ( make ARCH=${ARCH} CROSS_COMPILE="${TOOLCHAIN_PREFIX}" ${NJ} zImage modules ${KERNEL_DTB} ) ; then exit 6 ; fi
        fi
    popd

popd
