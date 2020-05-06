#!/bin/bash

install_deb_pkgs    \
    binutils        \
    debootstrap     \
    sudo            \
    fdisk           \
    lzop            \
    pv              \
    exfat-utils

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

FN=$(basename "${IMG_DEV_DISTRO}")
DN="${FN%.*}"

preAuthRoot && sudo mkdir -p "${SYSROOT}/opt/${DN}"

if ! ( preAuthRoot && sudo install -m 0755 "${COREDIR}"/*flash_image.sh "${SYSROOT}/opt/${DN}/" ) ; then exit 1 ; fi
if ! ( preAuthRoot && sudo install -m 0755 "${IMG_DEV_DISTRO}" "${SYSROOT}/opt/${DN}/" ) ; then exit 2 ; fi

preAuthRoot && echo "#!/bin/bash

export IMG_NAME=\"/opt/${DN}/${FN}\"
export HOST_MMC=\"${HOST_MMC}\"
export DEV_STORAGE_FS=\"${DEV_STORAGE_FS}\"
export DEV_STORAGE_LBL=\"${DEV_STORAGE_LBL}\"
export DEV_STORAGE_OTG=\"${DEV_STORAGE_OTG}\"
export DEV_FSTAB_MMC_PREFIX=\"${DEV_FSTAB_MMC_PREFIX}\"

function preAuthRoot() { return 0 ; }
export -f preAuthRoot

/bin/bash /opt/${DN}/*flash_image.sh" | sudo tee "${SYSROOT}/opt/${DN}/install.sh"

if ! ( preAuthRoot && sudo chmod +x "${SYSROOT}/opt/${DN}/install.sh" ) ; then exit 3 ; fi
