#!/bin/bash
show_current_task

exportdefvar IMX_GSTREAMER_BRANCH   "master"

exportdefvar IMX_GSTERANER_REVISION "889b8352ca09cd224be6a2f8d53efd59a38fa9cb" #

exportdefvar IMX_EGL                "fb"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# GET PACKAGES --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

IMX_GIT_URL="https://github.com/Freescale"

DEV_SRC_DIR="/usr/src/imx/gst"
if ! ( preAuthRoot && sudo mkdir -p "${SYSROOT}${DEV_SRC_DIR}" ) ; then exit 1 ; fi

if ! ( get_git_pkg "${IMX_GIT_URL}" "gstreamer-imx" "${IMX_GSTREAMER_BRANCH}" "${IMX_GSTERANER_REVISION}" )     ; then exit 1 ; fi
if ! ( preAuthRoot && sudo cp -R "${CACHE}/gstreamer-imx-${IMX_GSTREAMER_BRANCH}" "${SYSROOT}${DEV_SRC_DIR}/" ) ; then exit 1 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# INSTALL PACKAGES - --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

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

    pushd gstreamer-imx-${IMX_GSTREAMER_BRANCH}

        mkdir bin

        export CFLAGS=-I/usr/include
        export LDFLAGS=-L/usr/lib/arm-linux-gnueabihf

        if [[ \"\$PWD\" =~ \"v2\" ]] ; then
            run_cmd mkdir build
            pushd build
                run_cmd meson .. -Dprefix=${HOST_PREFIX}
                DESTDIR=bin run_cmd ninja install
            popd
        else
            run_cmd ./waf configure --prefix=${HOST_PREFIX} --kernel-headers=/include --g2d-includes=${HOST_PREFIX}/include --egl-platform=${IMX_EGL}
            run_cmd ./waf
            run_cmd ./waf install --destdir=bin
        fi

        install_to_sysroot
    popd

    echo ''
    gst-inspect-1.0 | grep imx
    echo ''

    GST_V4L2_CHK=\$(gst-inspect-1.0 | grep imxv4l2)
    if [ -z \"\$GST_V4L2_CHK\" ] ; then
        echo ''
        echo '>>> gstreamer-imx: V4L2 is not found'
        echo ''
        exit 1
    fi

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
echo "    IMX GST WAS SUCCESSFULLY INSTALLED!"
echo ""

exit 0
