#!/bin/bash
show_current_task

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

exportdefvar fbsrc_GITURL       "https://github.com/vianpl"
exportdefvar fbsrc_GITREPO      "fbsrc"
exportdefvar fbsrc_BRANCH       "master"
exportdefvar fbsrc_REVISION     ""
exportdefvar fbsrc_RECOMPILE    n

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# GET PACKAGES --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if ! ( get_git_pkg "${fbsrc_GITURL}" "${fbsrc_GITREPO}" "${fbsrc_BRANCH}" "${fbsrc_REVISION}" ) ; then goto_exit 1 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# INSTALL PACKAGES - --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

if ! pushd "${CACHE}/${fbsrc_GITREPO}-${fbsrc_BRANCH}" ; then goto_exit 2 ; fi

    # MAKE

    export KDIR="${CACHE}/linux-${KERNEL_fbsrc_BRANCH}"

    KVER=$(cd "${SYSROOT}/lib/" && ls "modules")
    KDIR=$(realpath -s "${SYSROOT}/lib/modules/${KVER}/build")

    if ( [ "${fbsrc_RECOMPILE}" != "n" ] || ! [ -f "fbsrc.ko" ] ) ; then
        make clean
        if ! ( make KDIR="${KDIR}" ) ; then goto_exit 3 ; fi
    fi

    # INSTALL

    preAuthRoot && sudo mkdir -p "${SYSROOT}/lib/modules/${KVER}/video"
    if ! ( preAuthRoot && sudo install -p -m 644 "fbsrc.ko" "${SYSROOT}/lib/modules/${KERNEL_RELEASE}/kernel/drivers/video/" ) ; then goto_exit 4 ; fi
    if ! ( preAuthRoot && sudo sudo chroot "${SYSROOT}" depmod -a "${KVER}" ) ; then goto_exit 5 ; fi

    preAuthRoot && echo "fbsrc" | sudo tee -a "${SYSROOT}/etc/modules"

popd

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

show_message "FBSRC WAS SUCCESSFULLY INSTALLED!"
