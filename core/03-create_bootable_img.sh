#!/bin/bash

exportdefvar IMG_DD_ARGS
exportdefvar IMG_BOOT_SIZE_MB       32

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

show_message "$(basename $0)"

if [ -f "${IMG_NAME}" ] ; then

    show_message "IMAGE ${IMG_NAME} ALREADY EXISIS!"
    exit 0
fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

if ! ( dd if="/dev/zero" bs=1M count="${IMG_SIZE_MB}" >> "${IMG_NAME}" ) ; then 

    show_message "CAN'T CREATE IMAGE FILE ${IMG_NAME}!"
    goto_exit 1
fi

sleep 3s ; sync

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

if [ -f "${CACHE}/${UBOOT_GITREPO}-${UBOOT_BRANCH}/SPL" ] ; then
    if ! ( dd conv=notrunc if="${CACHE}/${UBOOT_GITREPO}-${UBOOT_BRANCH}/SPL" of="${IMG_NAME}" ${IMG_DD_ARGS} )             ; then goto_exit 2 ; fi
    sync
    if [ -f "${CACHE}/${UBOOT_GITREPO}-${UBOOT_BRANCH}/u-boot.img" ] ; then
        exportdefvar IMG_DD_ARGS "bs=1K seek=69"
        if ! ( dd conv=notrunc if="${CACHE}/${UBOOT_GITREPO}-${UBOOT_BRANCH}/u-boot.img" of="${IMG_NAME}" ${IMG_DD_ARGS} )  ; then goto_exit 3 ; fi
    fi
elif [ -f "${CACHE}/${UBOOT_GITREPO}-${UBOOT_BRANCH}/u-boot.imx" ] ; then
    exportdefvar IMG_DD_ARGS "bs=1k seek=1 skip=0 oflag=dsync"
    if ! ( dd conv=notrunc if="${CACHE}/${UBOOT_GITREPO}-${UBOOT_BRANCH}/u-boot.imx" of="${IMG_NAME}" ${IMG_DD_ARGS} )      ; then goto_exit 4 ; fi
else
    show_message "UNABLE TO FIND uBoot IN "${CACHE}/${UBOOT_GITREPO}-${UBOOT_BRANCH}"!"
    goto_exit 5
fi

sleep 3s ; sync

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

sfdisk "${IMG_NAME}" << EOF
1M,${IMG_BOOT_SIZE_MB}M,0xE,*
,,,-
EOF
