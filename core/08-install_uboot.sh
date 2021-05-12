#!/bin/bash

show_message "$(basename $0)"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

if [ -f "${CACHE}/${UBOOT_GITREPO}-${UBOOT_BRANCH}/SPL" ] ; then
    if ! ( preAuthRoot && sudo install -m 0755 "${CACHE}/${UBOOT_GITREPO}-${UBOOT_BRANCH}/SPL" "${BOOT}/" ) ; then goto_exit 1 ; fi
fi

if [ -f "${CACHE}/${UBOOT_GITREPO}-${UBOOT_BRANCH}/u-boot.img" ] ; then
    if ! ( preAuthRoot && sudo install -m 0755 "${CACHE}/${UBOOT_GITREPO}-${UBOOT_BRANCH}/u-boot.img" "${BOOT}/" ) ; then goto_exit 2 ; fi
fi

pushd "${USERDIR}"
    if ! [ -z "${UBOOT_POSTINSTALL}" ] ; then
        if ! ( eval ${UBOOT_POSTINSTALL} ) ; then goto_exit 3 ; fi
    fi
popd
