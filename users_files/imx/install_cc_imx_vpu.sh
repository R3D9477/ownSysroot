#!/bin/bash

exportdefvar IMX_FIRMWARE               "firmware-imx-7.5"
exportdefvar IMX_VPU                    "imx-vpu-5.4.38"
exportdefvar IMX_CODEC                  "imx-codec-4.3.5"

exportdefvar IMX_DMABUFFER_BRANCH       "master"
exportdefvar IMX_DMABUFFER_REVISION     ""

exportdefvar IMX_VPUAPI_BRANCH          "master"
exportdefvar IMX_VPUAPI_REVISION        "4afb52f97e28c731c903a8538bf99e4a6d155b42"

exportdefvar IMX                        "imx6"

exportdefvar IMX_BIN_URL                "http://www.freescale.com/lgfiles/NMG/MAD/YOCTO"
exportdefvar IMX_GIT_URL                "https://github.com/Freescale"

exportdefvar DEV_SRC_DIR                "${HOST_PREFIX}/src/imx/vpu"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# GET PACKAGES --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if ! ( preAuthRoot && sudo mkdir -p "${SYSROOT}${DEV_SRC_DIR}" ) ; then goto_exit 1 ; fi

if ! ( get_bin_pkg "${IMX_BIN_URL}" "${IMX_FIRMWARE}" ) ; then goto_exit 2 ; fi
if ! ( preAuthRoot && sudo cp -R "${CACHE}/${IMX_FIRMWARE}" "${SYSROOT}${DEV_SRC_DIR}/" ) ; then goto_exit 3 ; fi

if ! ( get_bin_pkg "${IMX_BIN_URL}" "${IMX_VPU}" ) ; then goto_exit 4 ; fi
if ! ( preAuthRoot && sudo cp -R "${CACHE}/${IMX_VPU}" "${SYSROOT}${DEV_SRC_DIR}/" ) ; then goto_exit 5 ; fi

if ! ( get_bin_pkg "${IMX_BIN_URL}" "${IMX_CODEC}" ) ; then goto_exit 6 ; fi
if ! ( preAuthRoot && sudo cp -R "${CACHE}/${IMX_CODEC}" "${SYSROOT}${DEV_SRC_DIR}/" ) ; then goto_exit 7 ; fi

if ! ( get_git_pkg "${IMX_GIT_URL}" "libimxdmabuffer" "${IMX_DMABUFFER_BRANCH}" "${IMX_DMABUFFER_REVISION}" ) ; then goto_exit 8 ; fi
if ! ( preAuthRoot && sudo cp -R "${CACHE}/libimxdmabuffer-${IMX_DMABUFFER_BRANCH}" "${SYSROOT}${DEV_SRC_DIR}/" ) ; then goto_exit 9 ; fi

if ! ( get_git_pkg "${IMX_GIT_URL}" "libimxvpuapi" "${IMX_VPUAPI_BRANCH}" "${IMX_VPUAPI_REVISION}" ) ; then goto_exit 10 ; fi
if ! ( preAuthRoot && sudo cp -R "${CACHE}/libimxvpuapi-${IMX_VPUAPI_BRANCH}" "${SYSROOT}${DEV_SRC_DIR}/" ) ; then goto_exit 11 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# INSTALL PACKAGES - --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

transformFsToHost

# IMX FIRMWARE

    show_message "i.MX: INSTALL ${IMX_FIRMWARE}"

pushd "${CACHE}/${IMX_FIRMWARE}"

    if ! ( preAuthRoot && sudo cp -R "firmware" "${SYSROOT}/lib/" ) ; then goto_exit 12 ; fi
    if ! ( preAuthRoot && sudo chroot "${SYSROOT}" chmod -R +x "/lib/firmware" ) ; then goto_exit 13 ; fi

popd

# IMX VPU

    show_message "i.MX: INSTALL ${IMX_VPU}"

pushd "${CACHE}/${IMX_VPU}"

    rm -rf bin ; mkdir bin

    export CFLAGS="${CFLAGS} -O2"

    make clean
    if ! ( make PLATFORM=IMX6Q all ) ; then goto_exit 14 ; fi
    if ! ( DEST_DIR="bin" make install ) ; then goto_exit 15 ; fi

    install_to_sysroot "bin"
popd

    show_message "i.MX: INSTALL ${IMX_CODEC}"

pushd "${CACHE}/${IMX_CODEC}"

    rm -rf bin ; mkdir bin

    if ! ( ./autogen.sh --prefix=${HOST_PREFIX} --enable-fhw --enable-vpu ) ; then goto_exit 16 ; fi
    if ! ( make all ) ; then goto_exit 17 ; fi
    if ! ( DESTDIR=bin make install ) ; then goto_exit 18 ; fi

    install_to_sysroot "bin"
popd

    show_message "i.MX: INSTALL libimxdmabuffer-${IMX_DMABUFFER_BRANCH}"

pushd "${CACHE}/libimxdmabuffer-${IMX_DMABUFFER_BRANCH}"

    rm -rf bin ; mkdir bin

    if ! ( ./waf configure --prefix=${HOST_PREFIX} --imx-linux-headers-path="/include" --with-ipu-allocator=yes --with-g2d-allocator=yes ) ; then goto_exit 19 ; fi
    if ! ( ./waf ) ; then goto_exit 20 ; fi
    if ! ( ./waf install --destdir="bin" ) ; then goto_exit 21 ; fi

    install_to_sysroot "bin"
popd

    show_message "i.MX: INSTALL libimxvpuapi-${IMX_VPUAPI_BRANCH}"

pushd "${CACHE}/libimxvpuapi-${IMX_VPUAPI_BRANCH}"

    rm -rf bin ; mkdir bin

    if [[ "${PWD}" =~ "v2" ]]
    then WAF_PARAMS="--sysroot-path=\"${SYSROOT}\" --imx-headers=/include --imx-platform=${IMX}"
    fi

    if ! ( ./waf configure --prefix=${HOST_PREFIX} ${WAF_PARAMS} ) ; then goto_exit 22 ; fi
    if ! ( ./waf ) ; then goto_exit 23 ; fi
    if ! ( ./waf install --destdir=bin ) ; then goto_exit 24 ; fi

    install_to_sysroot "bin"
popd

transformFsToDevice

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

show_message "IMX VPU WAS SUCCESSFULLY INSTALLED!"
goto_exit 0
