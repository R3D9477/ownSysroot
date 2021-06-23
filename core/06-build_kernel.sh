#!/bin/bash
show_current_task

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

exportdefvar KERNEL_GITURL      ""
exportdefvar KERNEL_GITREPO     ""
exportdefvar KERNEL_BRANCH      ""
exportdefvar KERNEL_PRECOMPILE  ""
exportdefvar KERNEL_RECOMPILE   ""
exportdefvar KERNEL_CLEAN       ""
exportdefvar KERNEL_OUTPUT      "zImage"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

show_message                                    \
    "KERNEL_GITURL     : ${KERNEL_GITURL}"      \
    "KERNEL_GITREPO    : ${KERNEL_GITREPO}"     \
    "KERNEL_BRANCH     : ${KERNEL_BRANCH}"      \
    "KERNEL_PRECOMPILE : ${KERNEL_PRECOMPILE}"  \
    "KERNEL_RECOMPILE  : ${KERNEL_RECOMPILE}"   \
    "KERNEL_CLEAN      : ${KERNEL_CLEAN}"       \
    "KERNEL_OUTPUT     : ${KERNEL_OUTPUT}"

show_message_counter "    continue in:"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

if ! ( get_git_pkg "${KERNEL_GITURL}" "${KERNEL_GITREPO}" "${KERNEL_BRANCH}" ) ; then goto_exit 1 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

if ! pushd "${CACHE}" ; then goto_exit 2 ; fi

    pushd "${USERDIR}"
        if ! [ -z "${KERNEL_PRECOMPILE}" ] ; then
            if ! ( eval ${KERNEL_PRECOMPILE} ) ; then goto_exit 3 ; fi
        fi
    popd

    if ! pushd "${KERNEL_GITREPO}-${KERNEL_BRANCH}" ; then goto_exit 4 ; fi

        if ( [ "${KERNEL_RECOMPILE}" == "y" ] || ! [ -f "vmlinux" ] ) ; then

            if [ "${KERNEL_CLEAN}" != "n" ] ; then make clean ; fi

            if ! ( make ARCH=${ARCH} CROSS_COMPILE="${TOOLCHAIN_PREFIX}" ${NJ} ${KERNEL_CONFIG} ) ; then goto_exit 5 ; fi
            if ! ( make ARCH=${ARCH} CROSS_COMPILE="${TOOLCHAIN_PREFIX}" ${NJ} ${KERNEL_OUTPUT} modules ${KERNEL_DTB} ) ; then goto_exit 6 ; fi
        fi
    popd

popd
