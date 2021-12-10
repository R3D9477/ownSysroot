#!/bin/bash
show_current_task

exportdefvar IMX_FIRMWARE           "firmware-imx-7.5"
exportdefvar IMX_VPU                "imx-vpu-5.4.38"
exportdefvar IMX_CODEC              "imx-codec-4.3.5"

exportdefvar IMX_DMABUFFER_BRANCH   "master"
exportdefvar IMX_DMABUFFER_REVISION ""

exportdefvar IMX_VPUAPI_BRANCH      "master"
exportdefvar IMX_VPUAPI_REVISION    "4afb52f97e28c731c903a8538bf99e4a6d155b42"

exportdefvar IMX                    "imx6"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# GET PACKAGES --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

IMX_BIN_URL="http://www.freescale.com/lgfiles/NMG/MAD/YOCTO"
IMX_GIT_URL="https://github.com/Freescale"

DEV_SRC_DIR="/usr/src/imx/vpu"
if ! ( preAuthRoot && sudo mkdir -p "${SYSROOT}${DEV_SRC_DIR}" ) ; then exit 1 ; fi

if ! ( get_bin_pkg "${IMX_BIN_URL}" "${IMX_FIRMWARE}" ) ; then exit 1 ; fi
if ! ( preAuthRoot && sudo cp -R "${CACHE}/${IMX_FIRMWARE}" "${SYSROOT}${DEV_SRC_DIR}/" ) ; then exit 1 ; fi

if ! ( get_bin_pkg "${IMX_BIN_URL}" "${IMX_VPU}" ) ; then exit 1 ; fi
if ! ( preAuthRoot && sudo cp -R "${CACHE}/${IMX_VPU}" "${SYSROOT}${DEV_SRC_DIR}/" ) ; then exit 1 ; fi

if ! ( get_bin_pkg "${IMX_BIN_URL}" "${IMX_CODEC}" ) ; then exit 1 ; fi
if ! ( preAuthRoot && sudo cp -R "${CACHE}/${IMX_CODEC}" "${SYSROOT}${DEV_SRC_DIR}/" ) ; then exit 1 ; fi

if ! ( get_git_pkg "${IMX_GIT_URL}" "libimxdmabuffer" "${IMX_DMABUFFER_BRANCH}" "${IMX_DMABUFFER_REVISION}" ) ; then exit 1 ; fi
if ! ( preAuthRoot && sudo cp -R "${CACHE}/libimxdmabuffer-${IMX_DMABUFFER_BRANCH}" "${SYSROOT}${DEV_SRC_DIR}/" ) ; then exit 1 ; fi

if ! ( get_git_pkg "${IMX_GIT_URL}" "libimxvpuapi" "${IMX_VPUAPI_BRANCH}" "${IMX_VPUAPI_REVISION}" ) ; then exit 1 ; fi
if ! ( preAuthRoot && sudo cp -R "${CACHE}/libimxvpuapi-${IMX_VPUAPI_BRANCH}" "${SYSROOT}${DEV_SRC_DIR}/" ) ; then exit 1 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# INSTALL PACKAGES - --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

# IMX FIRMWARE
if ! ( preAuthRoot && sudo cp -R "${CACHE}/${IMX_FIRMWARE}/firmware" "${SYSROOT}/lib/" ) ; then exit 1 ; fi
if ! ( preAuthRoot && sudo chroot "${SYSROOT}" chmod -R +x "/lib/firmware" ) ; then exit 1 ; fi

# IMX VPU
if ! pushd "${SYSROOT}${DEV_SRC_DIR}" ; then exit 1 ; fi

    install_deb_pkgs autoconf automake build-essential libtool pkg-config python libpango1.0-dev

    transformFsToDevice

    preAuthRoot && echo "#!/bin/bash

function run_cmd() { if ! eval \$@ ; then echo \">>> command \$@ was failed\" ; exit 1 ; fi }

function install_to_sysroot() {

	if [ -d bin${HOST_PREFIX}/lib/pkgconfig ] ; then
		pushd bin${HOST_PREFIX}/lib/pkgconfig
			for PCFILE in *.pc ; do
				if [ -z \"$(cat \${PCFILE} | grep ${HOST_LIBDIR})\" ] ; then
					sed -i 's|/lib|${HOST_LIBDIR}|g' \${PCFILE}
				fi
			done
		popd
	fi

	if [ -d bin${HOST_PREFIX}/lib ] ; then
	    run_cmd cp -R bin${HOST_PREFIX}/lib/* ${HOST_PREFIX}${HOST_LIBDIR}/
	fi
	
	if [ -d bin${HOST_PREFIX}/include ] ; then
	    run_cmd cp -R bin${HOST_PREFIX}/include ${HOST_PREFIX}/
	fi
	
	if [ -d bin${HOST_PREFIX}/bin ] ; then
	    run_cmd cp -R bin${HOST_PREFIX}/bin ${HOST_PREFIX}/
	fi
	
	if [ -d bin${HOST_PREFIX}/share ] ; then
	    run_cmd cp -R bin${HOST_PREFIX}/share ${HOST_PREFIX}/
	fi
}

pushd ${DEV_SRC_DIR}

    rm .installed

    echo ''
    echo '>>> install imx_vpu'
    echo ''

    pushd ${IMX_VPU}

        rm -rf bin ; mkdir bin

        run_cmd make clean
        run_cmd make PLATFORM=IMX6Q all

        DEST_DIR=bin make install

        install_to_sysroot
    popd

    echo ''
    echo '>>> install imx_codec'
    echo ''

    pushd ${IMX_CODEC}

        rm -rf bin ; mkdir bin

        run_cmd ./autogen.sh --prefix=/usr --enable-fhw --enable-vpu
        run_cmd make all

        DESTDIR=bin run_cmd make install

        install_to_sysroot
    popd

    sync; sleep 1

    echo ''
    echo '>>> install imx_dmabuffer'
    echo ''

    pushd libimxdmabuffer-${IMX_DMABUFFER_BRANCH}

        rm -rf bin ; mkdir bin

        run_cmd ./waf configure --prefix=/usr --includedir=/usr/include  --imx-linux-headers-path=/include --with-ipu-allocator=yes --with-g2d-allocator=yes
        run_cmd ./waf

        run_cmd ./waf install --destdir=bin

        install_to_sysroot
    popd

    echo ''
    echo '>>> install imx_vpuapi'
    echo ''

    pushd libimxvpuapi-${IMX_VPUAPI_BRANCH}

        rm -rf bin ; mkdir bin

        if [[ \"\$PWD\" =~ \"v2\" ]] ; then run_cmd ./waf configure --prefix=/usr --sysroot-path=/ --imx-headers=/include --imx-platform=${IMX}
        else run_cmd ./waf configure --prefix=/usr --includedir=/usr/include
        fi
        run_cmd ./waf

        run_cmd ./waf install --destdir=bin

        install_to_sysroot
    popd

    sync

    echo 1 > .installed
popd

exit 0" | sudo tee "install.sh"

        preAuthRoot && sudo chroot "${SYSROOT}" chmod +x "${DEV_SRC_DIR}/install.sh"
        preAuthRoot && sudo chroot "${SYSROOT}" "${DEV_SRC_DIR}/install.sh"

        if ! [ -f ".installed" ] ; then exit 1 ; fi

    fix_chmod

popd

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

echo ""
echo "    IMX VPU WAS SUCCESSFULLY INSTALLED!"
echo ""

exit 0
