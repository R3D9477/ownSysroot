exportdefvar COREDIR   "$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
exportdefvar USERDIR   "${COREDIR}/../users_files"
exportdefvar CACHE     "${COREDIR}/../../cache"
exportdefvar MOUNT     "${COREDIR}/../../mount"
exportdefvar IMGDIR    "${COREDIR}/../../images"

export USERDIR=$(realpath  -s -m "${USERDIR}")
export CACHE=$(realpath    -s -m "${CACHE}")
export MOUNT=$(realpath    -s -m "${MOUNT}")
export IMGDIR=$(realpath   -s -m "${IMGDIR}")
export BOOT=$(realpath     -s -m "${MOUNT}/boot")
export SYSROOT=$(realpath  -s -m "${MOUNT}/sysroot")
export IMG_NAME=$(realpath -s -m "${IMGDIR}/${IMG_NAME}")

show_message                         \
    "USERDIR  : ${USERDIR}"          \
    "CACHE    : ${CACHE}"            \
    "MOUNT    : ${MOUNT}"            \
    "IMGDIR   : ${IMGDIR}"           \
    "BOOT     : ${BOOT}"             \
    "SYSROOT  : ${SYSROOT}"          \
    "IMG_NAME : ${IMG_NAME}"         \
    "IMG_SIZE : ${IMG_SIZE_MB}Mb"

prepare_fs
fix_chmod
