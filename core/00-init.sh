export COREDIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

if [ -z "${USERDIR}" ] ; then export USERDIR="${COREDIR}/../users_files" ; fi
if [ -z "${CACHE}"   ] ; then export CACHE="${COREDIR}/../../cache"   ; fi
if [ -z "${MOUNT}"   ] ; then export MOUNT="${COREDIR}/../../mount"   ; fi
if [ -z "${IMGDIR}"  ] ; then export IMGDIR="${COREDIR}/../../images" ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

SECONDS=0
function showElapsedTime() {

    duration=${SECONDS}

    echo ""
    echo "  $((${duration} / 60)) min. $((${duration} % 60)) sec. elapsed"
    echo ""
}
export -f showElapsedTime

function preAuthRoot () {

    if eval "echo ${HOST_PASS} | sudo -S printf ''" ; then return 0
    else return 1
    fi
}
export -f preAuthRoot

function prepare_dir() {

    DIRPATH=$(realpath -s "$1")

    if ! [ -d "${DIRPATH}" ] && ! [ -z "${DIRPATH}" ] ; then
        if ! mkdir -p "${DIRPATH}" ; then exit 1 ; fi
    fi
}

function prepare_fs() {

    prepare_dir "${USERDIR}"

    prepare_dir "${CACHE}"
    prepare_dir "${MOUNT}"
    prepare_dir "${IMGDIR}"

    prepare_dir "${BOOT}"
    prepare_dir "${SYSROOT}"
}

function rm_wrk_dir () {

    if [ -d "$1" ]; then
        preAuthRoot && sudo fuser -k -9 $(realpath -s "$1")
        preAuthRoot && sudo umount $(realpath -s "$1")
        preAuthRoot && sudo rm -rf $(realpath -s "$1")
    fi
}

function rm_all_wrk_dirs() {

    rm_wrk_dir "${SYSROOT}/sys"
    rm_wrk_dir "${SYSROOT}/proc"
    rm_wrk_dir "${SYSROOT}/dev/pts"
    rm_wrk_dir "${SYSROOT}/dev"
    rm_wrk_dir "${SYSROOT}"
    rm_wrk_dir "${BOOT}"
    rm_wrk_dir "${MOUNT}"

    rm_wrk_dir "/media/${USER}/SYSROOT"
    rm_wrk_dir "/media/${USER}/BOOT"

    return 0
}

function close_all_imgs() {

    QEMU_PROC_ID=$(ps axf | grep dbus-daemon | grep qemu-arm-static | awk '{print $1}')
    if [ -n "${QEMU_PROC_ID}" ] ; then kill -9 ${QEMU_PROC_ID} ; fi

    shopt -s nullglob
    for fimg in $(realpath -s "${IMGDIR}")/*.img ; do
        sync
        preAuthRoot && sudo kpartx -d $(realpath -s "$fimg")
        sleep 1s
        if [ "$1" == "y" ] ; then rm -f $(realpath -s "$fimg") ; fi
    done

    return 0
}

function clean_all() {

    rm_all_wrk_dirs
    prepare_fs
    close_all_imgs "$1"
}
export -f clean_all

function install_deb_pkgs() {

    if ! ( preAuthRoot && sudo sudo chroot "${SYSROOT}" apt install $@ -y ) ; then

        echo ""
        echo ">>> APT FIX-MISSING"
        echo ""

        sleep 3s
        preAuthRoot && sudo chroot "${SYSROOT}" apt update --fix-missing -y

        if ! ( preAuthRoot && sudo sudo chroot "${SYSROOT}" apt install $@ -y ) ; then exit 3 ; fi
    fi

    preAuthRoot && sudo chroot "${SYSROOT}" apt autoremove -y
    preAuthRoot && sudo chroot "${SYSROOT}" apt clean -y
}
export -f install_deb_pkgs

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

export USERDIR=$(realpath -s -m "${USERDIR}")
export CACHE=$(realpath -s -m "${CACHE}")
export MOUNT=$(realpath -s -m "${MOUNT}")
export IMGDIR=$(realpath -s -m "${IMGDIR}")

export BOOT=$(realpath -s -m "${MOUNT}/boot")
export SYSROOT=$(realpath -s -m "${MOUNT}/sysroot")
export IMG_NAME=$(realpath -s -m "${IMGDIR}/${IMG_NAME}")
