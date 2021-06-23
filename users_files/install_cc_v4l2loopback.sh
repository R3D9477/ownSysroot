#!/bin/bash
show_current_task

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

exportdefvar v4l2loopback_GIT_URL       "https://github.com/umlaeute"
exportdefvar v4l2loopback_GITREPO       "v4l2loopback"
exportdefvar v4l2loopback_BRANCH        "main"
exportdefvar v4l2loopback_REVISION      ""
exportdefvar v4l2loopback_RECOMPILE     n

exportdefvar v4l2loopback_MOD_OPS       "devices=1 video_nr=50"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# GET PACKAGES

if ! ( get_git_pkg "${v4l2loopback_GIT_URL}" "${v4l2loopback_GITREPO}" "${v4l2loopback_BRANCH}" "${v4l2loopback_REVISION}" ) ; then goto_exit 1 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# INSTALL PACKAGES

if ! pushd "${CACHE}/${v4l2loopback_GITREPO}-${v4l2loopback_BRANCH}" ; then goto_exit 2 ; fi

    # MAKE

    export KDIR="${CACHE}/linux-${KERNEL_v4l2loopback_BRANCH}"

    KERNEL_RELEASE=$(cd "${SYSROOT}/lib/" && ls "modules")
    KERNEL_DIR=$(realpath -s "${SYSROOT}/lib/modules/${KERNEL_RELEASE}/build")

    if ( [ "${v4l2loopback_RECOMPILE}" != "n" ] || ! [ -f "v4l2loopback.ko" ] ) ; then
        make clean
        if ! ( make ARCH=${ARCH} CROSS_COMPILE="${TOOLCHAIN_PREFIX}" KERNEL_RELEASE="${KERNEL_RELEASE}" KERNEL_DIR="${KERNEL_DIR}" $NJ ) ; then goto_exit 3 ; fi
    fi

    # INSTALL

    preAuthRoot && sudo mkdir -p "${SYSROOT}/lib/modules/${KERNEL_RELEASE}/kernel/drivers/video/"
    if ! ( preAuthRoot && sudo install -p -m 644 "v4l2loopback.ko" "${SYSROOT}/lib/modules/${KERNEL_RELEASE}/kernel/drivers/video/" ) ; then goto_exit 4 ; fi
    if ! ( preAuthRoot && sudo chroot "${SYSROOT}" depmod -a "${KERNEL_RELEASE}" ) ; then goto_exit 5 ; fi

    if [ -z "$(cat ${SYSROOT}/etc/modules | grep v4l2loopback)" ] ; then
        preAuthRoot && echo "v4l2loopback" | sudo tee -a "${SYSROOT}/etc/modules"
    fi

    preAuthRoot && echo "options v4l2loopback ${v4l2loopback_MOD_OPS}" | sudo tee "${SYSROOT}/etc/modprobe.d/v4l2loopback.conf"

    sed -i "s|sudo||g" "utils/v4l2loopback-ctl"
    if ! ( preAuthRoot && sudo install -p -m 755 "utils/v4l2loopback-ctl" "${SYSROOT}/usr/bin/" ) ; then goto_exit 6 ; fi

popd

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

show_message "V4L2LOOPBACK WAS SUCCESSFULLY INSTALLED!"
