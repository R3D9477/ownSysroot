#!/bin/bash

if [ -f "${CACHE}/u-boot-edm/SPL" ] ; then
    if ! ( preAuthRoot && sudo install -m 0755 "${CACHE}/u-boot-edm/SPL" "${BOOT}/" ) ; then exit 1 ; fi
fi

if [ -f "${CACHE}/u-boot-edm/u-boot.img" ] ; then
    if ! ( preAuthRoot && sudo install -m 0755 "${CACHE}/u-boot-edm/u-boot.img" "${BOOT}/" ) ; then exit 2 ; fi
fi

pushd "${USERDIR}"
    if ! [ -z "${UBOOT_POSTINSTALL}" ] ; then
        if ! ( eval ${UBOOT_POSTINSTALL} ) ; then exit 3 ; fi
    fi
popd
