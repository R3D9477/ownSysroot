
if [ -z "${_00FUNC}" ] ; then

    export _00FUNC=1

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

function exportdefvar() {

    if ( ! [ "${!1}" ] && [ "$2" ] ) ; then eval "export $1=\"${2}\"" ; fi
}
export -f exportdefvar

function show_message() {

    echo ""
    for MSG in "$@" ; do echo "    ${MSG}" ; done
    echo ""
}
export -f show_message

function show_message_counter() {

    show_message "$1"
    for i in $(seq 1 10); do echo "        $((11-$i)) second(s)..." ; sleep 1s ; done
    echo ""
}
export -f show_message_counter

function show_current_task() {

    CT_NAME="$(basename $0)"

    LINE1="*"
    for (( i=0; i<$((${#CT_NAME}+9)); i++ )) ; do LINE1="${LINE1}*" ; done

    LINE2="***  "
    for (( i=0; i<$((${#CT_NAME}+2)); i++ )) ; do LINE2="${LINE2} " ; done
    LINE2="${LINE2}***"

    echo ""
    show_message                \
        "${LINE1}"              \
        "${LINE1}"              \
        "${LINE2}"              \
        "***  ${CT_NAME}  ***"  \
        "${LINE2}"              \
        "${LINE1}"              \
        "${LINE1}"
}
export -f show_current_task

SECONDS=0
function showElapsedTime() {

    duration=${SECONDS}
    show_message "$((${duration} / 60)) min. $((${duration} % 60)) sec. elapsed"
}
export -f showElapsedTime

function sync_fs() {

    echo "    sync filesystem..."

    sleep 3s

    sync
    #sync -d "${CACHE}"
    #sync -d "${MOUNT}"
    #sync -d "${IMGDIR}"

    echo "        done."
}
export -f sync_fs

function goto_exit() {

    showElapsedTime
    #transformFsToDevice

    if ( [[ $# != 0 ]] && [[ $1 != 0 ]] ) ; then
        show_message "ERROR CODE: $@"
        exit $@
    fi
}
export -f goto_exit

function preAuthRoot () {

    if eval "echo ${HOST_PASS} | sudo -S printf ''" ; then return 0
    else return 1
    fi
}
export -f preAuthRoot

function chroot_script() {

    CHRCMD="$@"
    CHRCMD="${CHRCMD//[$'\t\r\n']}"

    show_message "CHROOT: ${CHRCMD}"

    preAuthRoot
    if ! [ -f "${SYSROOT}/usr/bin/qemu-arm-static" ] ; then sudo cp "/usr/bin/qemu-arm-static" "${SYSROOT}/usr/bin/qemu-arm-static" ; fi

    if ( sudo chroot "${SYSROOT}" "/usr/bin/qemu-arm-static" "/bin/bash" -c "${CHRCMD}" ) ; then return 0 ; fi

    return 1
}
export -f chroot_script

function prepare_dir() {

    DIRPATH=$(realpath -s "$1")

    if ! [ -d "${DIRPATH}" ] && ! [ -z "${DIRPATH}" ] ; then
        if ! mkdir -p "${DIRPATH}" ; then goto_exit 1 ; fi
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
export -f prepare_fs

function rm_wrk_dir () {

    if [ -d "$1" ]; then

        RMFPATH=$(realpath -s "$1")

        show_message "REMOVE DIR: ${RMFPATH}"

        preAuthRoot && sudo fuser -k -9 "${RMFPATH}"
        preAuthRoot && sudo umount -l   "${RMFPATH}"
        preAuthRoot && sudo umount -f   "${RMFPATH}"
        preAuthRoot && sudo rm -rf      "${RMFPATH}"

        show_message "    done."
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

function close_img() {

    preAuthRoot && sudo kpartx -d "$1"

    if [ "$2" == "y" ] ; then rm -f "$1" ; fi

    RMLODEV=$(losetup | grep $(basename "$1") | awk '{ print $1 }')

    if ! [ -z "${RMLODEV}" ] ; then

        echo "REMOVE LO DEV: ${RMLODEV}"

        preAuthRoot && sudo fuser -k ${RMLODEV}
        preAuthRoot && sudo fuser -c ${RMLODEV}
        preAuthRoot && sudo fuser -f ${RMLODEV}
    fi
}

function close_all_imgs() {

    QEMU_PROC_ID=$(ps axf | grep dbus-daemon | grep qemu-arm-static | awk '{print $1}')
    if [ -n "${QEMU_PROC_ID}" ] ; then kill -9 ${QEMU_PROC_ID} ; fi

    close_img "${IMG_NAME}" "$1"

    shopt -s nullglob
    for RMIMG in $(realpath -s "${IMGDIR}")/*.img ; do close_img "${RMIMG}" "$1" ; done

    return 0
}

function clean_all() {

    show_message "CLEAN ALL: beginning"

    sync_fs

    rm_all_wrk_dirs
    prepare_fs

    close_all_imgs "$1"

    show_message "CLEAN ALL: done."
}
export -f clean_all

function fix_chmod() {

    PM=755
    preAuthRoot && sudo chmod -R ${PM} "${SYSROOT}/etc"
    preAuthRoot && sudo chmod -R ${PM} "${SYSROOT}/usr/bin"
    preAuthRoot && sudo chmod -R ${PM} "${SYSROOT}/usr/include"
    preAuthRoot && sudo chmod -R ${PM} "${SYSROOT}/usr/lib/arm-linux-gnueabihf"

    preAuthRoot && sudo chown ${USER}:${USER} "${CACHE}"
}
export -f fix_chmod

function install_to_sysroot() {

    BINDIR="$1"

    if [ -d "${BINDIR}${HOST_PREFIX}/lib/pkgconfig" ] ; then
        pushd "${BINDIR}${HOST_PREFIX}/lib/pkgconfig"
            for PCFILE in *.pc ; do
                if [ -z "$(cat ${PCFILE} | grep ${HOST_LIBDIR})" ] ; then
                    sed -i "s|/lib|${HOST_LIBDIR}|g" "${PCFILE}"
                fi
            done
        popd
    fi

    if [ -d "${BINDIR}${HOST_PREFIX}/lib" ] ; then
        preAuthRoot && sudo cp -R "${BINDIR}${HOST_PREFIX}/lib"/* "${SYSROOT}${HOST_PREFIX}${HOST_LIBDIR}"/
    fi

    if [ -d "${BINDIR}${HOST_PREFIX}/include" ] ; then
        preAuthRoot && sudo cp -R "${BINDIR}${HOST_PREFIX}/include" "${SYSROOT}${HOST_PREFIX}"/
    fi

    if [ -d "${BINDIR}${HOST_PREFIX}/bin" ] ; then
        preAuthRoot && sudo cp -R "${BINDIR}${HOST_PREFIX}/bin" "${SYSROOT}${HOST_PREFIX}"/
    fi

    if [ -d "${BINDIR}${HOST_PREFIX}/share" ] ; then
        preAuthRoot && sudo cp -R "${BINDIR}${HOST_PREFIX}/share" "${SYSROOT}${HOST_PREFIX}"/
    fi

    fix_chmod
}
export -f install_to_sysroot

function install_deb_pkgs() {

    if ! ( chroot_script apt install $@ -y ) ; then

        show_message "*** APT: TRY TO FIX MISSING ***"

        sleep 3s
        chroot_script apt update --fix-missing -y

        if ! ( chroot_script apt install $@ -y ) ; then goto_exit 3 ; fi
    fi

    chroot_script apt autoremove -y
    chroot_script apt clean -y
}
export -f install_deb_pkgs

function get_bin_pkg() {

    if ! pushd "${CACHE}" ; then goto_exit 1 ; fi
        if ! [ -d "$2" ]  ; then
            if ! [ -f "$2.bin" ] ; then
                if ! ( wget -nc -O "$2.bin" "$1/$2.bin" ) ; then goto_exit 2 ; fi
            fi
            chmod +x "$2.bin"
            if ! ( preAuthRoot && sudo ./"$2.bin" --force --auto-accept ) ; then goto_exit 3 ; fi
        fi
    popd

    fix_chmod
    preAuthRoot && sudo chown ${USER}:${USER} "${CACHE}/$2"
}
export -f get_bin_pkg

function get_git_pkg() {

    GIT_URL="$1"

    if ( [ -z "$3" ] && [ "${GIT_URL##*.}" == "git" ] ) ; then
        # FMT: <GIT_URL/PKG_NAME.git> <BRANCH> [REVISION]
        GIT_DIR=$(basename -- "${GIT_URL}")
        GIT_DIR=${GIT_DIR%.*}
        GIT_BRANCH="$2"
    else
        # FMT: <GIT_URL> <PKG_NAME> <BRANCH> [REVISION]
        GIT_DIR="$2"
        GIT_BRANCH="$3"
    fi

    if [ "${GIT_URL##*.}" != "git" ] ; then
        case "${GIT_URL}" in
        */) GIT_URL="${GIT_URL}${GIT_DIR}.git"  ;;
        *)  GIT_URL="${GIT_URL}/${GIT_DIR}.git" ;;
        esac
    fi

    GIT_REVISION="$4"

    GIT_DIR="${GIT_DIR}-${GIT_BRANCH}"

    if ! pushd "${CACHE}" ; then goto_exit 1 ; fi
        if ! [ -d "${GIT_DIR}" ] ; then
            if [ -f "${GIT_DIR}.tar" ] ; then
                if ! ( preAuthRoot && sudo tar -xpf "${GIT_DIR}.tar" ) ; then goto_exit 2 ; fi
            else
                unset SB_FLAG
                if [ -z "${GIT_REVISION}" ] ; then SB_FLAG="--single-branch" ; fi
                if ! ( git clone -b "${GIT_BRANCH}" ${SB_FLAG} "${GIT_URL}" "${GIT_DIR}" ) ; then goto_exit 3 ; fi
                if ! ( tar -cf "${GIT_DIR}.tar" "${GIT_DIR}" ) ; then goto_exit 4 ; fi
            fi
        fi

        fix_chmod
        preAuthRoot && sudo chown "${USER}":"${USER}" "${CACHE}/${GIT_DIR}"

        if ! pushd "${GIT_DIR}" ; then goto_exit 5 ; fi
            if ! [ -z "${GIT_REVISION}" ] ; then
                if ! ( git checkout "${GIT_REVISION}" ) ; then goto_exit 6 ; fi
                if ! ( git reset --hard "${GIT_REVISION}" ) ; then goto_exit 7 ; fi
            fi
        popd
    popd
}
export -f get_git_pkg

function link2host() {

    if ! [ -L "$1.device_link" ] ; then

        echo "    link2host: $1 $1.device_link"

        if ( preAuthRoot && sudo mv "$1" "$1.device_link" ) ; then

            if ( preAuthRoot && sudo ln -s "$SYSROOT"$(readlink "$1.device_link") "$1" ) ; then
                preAuthRoot && sudo chmod +r "$1"
                return 0
            fi
        fi

        return 1;
    fi

    return 0
}
export -f link2host

function link2device() {

    if [ -L "$1.device_link" ] ; then

        echo "    link2device $1.device_link --> $1"

        preAuthRoot && sudo rm "$1"
        if ( preAuthRoot && sudo mv "$1.device_link" "$1" ) ; then return 0 ; fi

        return 1
    fi

    return 0
}
export -f link2device

function transformLink() {

    if [ -L "$1" ]; then

        TRGPATH=$(readlink "$1")
        if [ "${TRGPATH:0:1}" == '/' ] && [ "$TRGPATH" != "$SYSROOT"* ]; then

            if [ "$2" == "device" ] ; then link2device "$1"
            elif [ "$2" == "host" ] ; then link2host "$1"
            fi

            transformLink "$(readlink $1)" "$2"
        fi
    fi

    return 0
}
export -f transformLink

function transformDir() {

    if [ -z "$3" ] ; then for OBJPATH in "$2"/* ; do transformLink "$OBJPATH" "$1" ; done
    else transformLink "$2"/"$3" "$1"
    fi

    return 0
}
export -f transformDir

function transformFsToHost() {

    if ! [ -d "${SYSROOT}" ] ; then return 1 ; fi

    transformDir "host" "${SYSROOT}/usr/lib/arm-linux-gnueabihf/pkgconfig"

    transformDir "host" "${SYSROOT}/usr/lib/arm-linux-gnueabihf" "libm.so"
    transformDir "host" "${SYSROOT}/usr/lib/arm-linux-gnueabihf" "libdl.so"
    transformDir "host" "${SYSROOT}/usr/lib/arm-linux-gnueabihf" "librt.so"
    transformDir "host" "${SYSROOT}/usr/lib/arm-linux-gnueabihf" "libffi.so"
    transformDir "host" "${SYSROOT}/usr/lib/arm-linux-gnueabihf" "libmount.so"
    transformDir "host" "${SYSROOT}/usr/lib/arm-linux-gnueabihf" "libresolv.so"
    transformDir "host" "${SYSROOT}/usr/lib/arm-linux-gnueabihf" "libpthread.so"
    transformDir "host" "${SYSROOT}/usr/lib/arm-linux-gnueabihf" "libglib-2.0.so"
}
export -f transformFsToHost

function transformFsToDevice() {

    if ! [ -d "${SYSROOT}" ] ; then return 1 ; fi

    transformDir "device" "${SYSROOT}/usr/lib/arm-linux-gnueabihf/pkgconfig"

    transformDir "device" "${SYSROOT}/usr/lib/arm-linux-gnueabihf" "libm.so"
    transformDir "device" "${SYSROOT}/usr/lib/arm-linux-gnueabihf" "libdl.so"
    transformDir "device" "${SYSROOT}/usr/lib/arm-linux-gnueabihf" "librt.so"
    transformDir "device" "${SYSROOT}/usr/lib/arm-linux-gnueabihf" "libffi.so"
    transformDir "device" "${SYSROOT}/usr/lib/arm-linux-gnueabihf" "libmount.so"
    transformDir "device" "${SYSROOT}/usr/lib/arm-linux-gnueabihf" "libresolv.so"
    transformDir "device" "${SYSROOT}/usr/lib/arm-linux-gnueabihf" "libpthread.so"
    transformDir "device" "${SYSROOT}/usr/lib/arm-linux-gnueabihf" "libglib-2.0.so"
}
export -f transformFsToDevice

function mount_sysroot() {

    preAuthRoot && sudo mount -o bind "/proc" "${SYSROOT}/proc"

    preAuthRoot && sudo mkdir -p -m 755 "${SYSROOT}/dev/pts"
    preAuthRoot && mount -t devtmpfs -o mode=0755,nosuid devtmpfs "${SYSROOT}/dev"
    preAuthRoot && mount -t devpts -o gid=5,mode=620 devpts "${SYSROOT}/dev/pts"
}
export -f mount_sysroot

function try_to_extract_sysroot() {

    if [ -f "${CACHE}/$1.tar" ]; then

        if ( preAuthRoot && sudo tar -C "${SYSROOT}" -xpf "${CACHE}/$1.tar" --strip-components=1 ) ; then

            if ( preAuthRoot && sudo chmod -R +r "${SYSROOT}" ) ; then

                preAuthRoot && sudo cp "/usr/bin/qemu-arm-static" "${SYSROOT}/usr/bin"
                mount_sysroot

                show_message "SYSROOT PACKAGE WAS SUCCESSFULLY EXTRACTED!"

                exit 0
            fi
        fi

        show_message "SYSROOT PACKAGE \"${CACHE}/$1.tar\" IS DAMAGED!"

        goto_exit 1
    fi
}
export -f try_to_extract_sysroot

function make_sysroot_package() {

    preAuthRoot && sudo tar --exclude="proc/*" -C "${SYSROOT}/.." -cf "${CACHE}/$1.tar" "sysroot"
}
export -f make_sysroot_package

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

fi
