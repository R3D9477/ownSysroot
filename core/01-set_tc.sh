
if [ ! "${TC_URL}" ] ; then
    TC_URL="https://releases.linaro.org/components/toolchain/binaries/latest-7/arm-linux-gnueabihf/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz"
fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

if ! pushd "${CACHE}" ; then goto_exit 1 ; fi

    if ! [ -f "gcc-arm-linux-gnueabihf.tar.xz" ] ; then
        if ! ( wget -nc -O "gcc-arm-linux-gnueabihf.tar.xz" "${TC_URL}" ) ; then goto_exit 2 ; fi
    fi

    gccdir=(gcc-*arm-linux-gnueabihf)
    if ! [ -e "${gccdir[0]}" ]; then
        show_message "EXTRACT TOOLCHAIN: ${CACHE}/gcc-arm-linux-gnueabihf.tar.xz"
        if ! ( preAuthRoot && sudo tar -xpf "gcc-arm-linux-gnueabihf.tar.xz" ) ; then goto_exit 3 ; fi
        show_message "    done."
    fi

popd

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

unset PKG_CONFIG_SYSROOT_DIR
unset CONFIGURE_FLAGS
unset CFLAGS
unset CPPFLAGS
unset CXXFLAGS
unset LDFLAGS
unset LDFLAGS
unset LINKFLAGS

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

exportdefvar ARCH               "arm"
exportdefvar mARCH              "armv7-a"

exportdefvar SDK_PATH_NATIVE    $(realpath -s "${CACHE}"/gcc-*arm-linux-gnueabihf)

exportdefvar TOOLCHAIN_SYS      "arm-linux-gnueabihf"
exportdefvar TOOLCHAIN_PREFIX   "${SDK_PATH_NATIVE}/bin/${TOOLCHAIN_SYS}-"

exportdefvar HOST_PREFIX        "/usr"
exportdefvar HOST_LIBDIR        "/lib/${TOOLCHAIN_SYS}"

exportdefvar PKG_CONFIG_LIBDIR  "${SYSROOT}${HOST_PREFIX}/lib/pkgconfig:${SYSROOT}${HOST_PREFIX}${HOST_LIBDIR}/pkgconfig"

exportdefvar CONFIGURE_FLAGS    " --with-libtool-sysroot=${SYSROOT}"
exportdefvar CFLAGS             " -O2 --sysroot=${SYSROOT} -march=${mARCH} -I${SYSROOT}/include -I${SYSROOT}${HOST_PREFIX}/include"
exportdefvar CPPFLAGS           "${CFLAGS}"
exportdefvar CXXFLAGS           "${CFLAGS}"
exportdefvar LDFLAGS            " --sysroot=${SYSROOT} -march=${mARCH} -Wl,-rpath-link,${SYSROOT}/lib/${TOOLCHAIN_SYS} -Wl,-rpath-link,${SYSROOT}${HOST_PREFIX}${HOST_LIBDIR}"
exportdefvar LINKFLAGS          "${LDFLAGS}"

#export LDFLAGS="${LDFLAGS} -Bsymbolic-functions --hash-style=gnu"

exportdefvar AR                 "${TOOLCHAIN_PREFIX}ar"
exportdefvar CC                 "${TOOLCHAIN_PREFIX}gcc"
exportdefvar CXX                "${TOOLCHAIN_PREFIX}g++"
exportdefvar CROSS_COMPILE      "${TOOLCHAIN_PREFIX}"
exportdefvar CHOST              "${TOOLCHAIN_SYS}"
exportdefvar RANLIB             "${TOOLCHAIN_PREFIX}ranlib"

NJBUF="-j$(nproc)"
if (( $NJBUF > 1 )) ; then NJBUF=$((NJBUF/2)) ; fi

exportdefvar NJ                 "${NJBUF}"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

export PATH="${SDK_PATH_NATIVE}/bin:${PATH}"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

if [ "${GCC_DBG}" == "y" ]; then

    show_message                    \
        "GCC Serch Dirs:"           \
        "   LDFLAGS  = ${LDFLAGS}"  \
        "   CPPFLAGS = ${CPPFLAGS}"

    ${SDK_PATH_NATIVE}/bin/arm-linux-gnueabihf-g++ --version
    ${SDK_PATH_NATIVE}/bin/arm-linux-gnueabihf-g++ -print-search-dirs
    echo ""

    show_message_counter "Continue in:"
fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

if [ "${GENERATE_MESON_INI}" == "y" ]; then

    exportdefvar MESON_INI_FILE "${CACHE}/meson_cross_compile.ini"

    echo "[host_machine]
system = 'linux'
cpu_family = '${ARCH}'
cpu = '${mARCH}'
endian = 'little'

[build_machine]
system = 'linux'
cpu_family = '`uname -m`'
endian = 'little'

[binaries]
c = '${TOOLCHAIN_PREFIX}gcc'
cpp = '${TOOLCHAIN_PREFIX}g++'
ar = '${TOOLCHAIN_PREFIX}ar'
strip = '${TOOLCHAIN_PREFIX}strip'
pkgconfig = 'pkg-config'

[properties]
root = '${SYSROOT}'
sys_root = '${SYSROOT}'
pkg_config_libdir = [ '${SYSROOT}${HOST_PREFIX}/lib/pkgconfig', '${SYSROOT}${HOST_PREFIX}${HOST_LIBDIR}/pkgconfig' ]
c_args = [ '--sysroot=${SYSROOT}' ]
cpp_args = [ '--sysroot=${SYSROOT}' ]
link_args = [ '--sysroot=${SYSROOT}', '-Wl,-rpath-link,${SYSROOT}/lib/${TOOLCHAIN_SYS}', '-Wl,-rpath-link,${SYSROOT}${HOST_PREFIX}${HOST_LIBDIR}' ]" | tee "${MESON_INI_FILE}"

fi
