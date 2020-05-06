if [ ! "${TC_URL}" ] ; then
    TC_URL="https://releases.linaro.org/components/toolchain/binaries/latest-7/arm-linux-gnueabihf/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz"
fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if ! pushd "${CACHE}" ; then exit 1 ; fi

    if ! [ -f "gcc-arm-linux-gnueabihf.tar.xz" ] ; then
        if ! wget -nc -O "gcc-arm-linux-gnueabihf.tar.xz" "${TC_URL}" ; then exit 1 ; fi
    fi

    gccdir=(gcc-*arm-linux-gnueabihf)
    if ! [ -e "${gccdir[0]}" ]; then
        if ! tar -xvf "gcc-arm-linux-gnueabihf.tar.xz" ; then exit 2 ; fi
    fi

popd

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

unset  LDFLAGS

export ARCH=arm
export SDK_PATH_NATIVE=$(realpath -s "${CACHE}"/gcc-*arm-linux-gnueabihf)

export SDK_PATH_TARGET=$(realpath -s "${SYSROOT}")
export TOOLCHAIN_SYS="arm-linux-gnueabihf"
export TOOLCHAIN_PREFIX="${SDK_PATH_NATIVE}/bin/${TOOLCHAIN_SYS}-"

export PATH="${SDK_PATH_NATIVE}/bin:${PATH}"

export PKG_CONFIG_SYSROOT_DIR=
export PKG_CONFIG_LIBDIR="${SDK_PATH_TARGET}/usr/lib/pkgconfig:${SDK_PATH_TARGET}/usr/lib/arm-linux-gnueabihf/pkgconfig"

export CONFIGURE_FLAGS=" --with-libtool-sysroot=${SDK_PATH_TARGET}"
export CFLAGS=" --sysroot=${SDK_PATH_TARGET}"
export CPPFLAGS=${CFLAGS}
export CXXFLAGS=${CFLAGS}
export LDFLAGS=" --sysroot=${SDK_PATH_TARGET}"
export LDFLAGS="${LDFLAGS} -Wl,-rpath-link,${SDK_PATH_TARGET}/lib/arm-linux-gnueabihf"
export LDFLAGS="${LDFLAGS} -Wl,-rpath-link,${SDK_PATH_TARGET}/usr/lib/arm-linux-gnueabihf"

export CHOST=${TOOLCHAIN_SYS}

export CC="${TOOLCHAIN_PREFIX}"gcc
export CXX="${TOOLCHAIN_PREFIX}"g++
export AR="${TOOLCHAIN_PREFIX}"ar
export CROSS_COMPILE="${TOOLCHAIN_PREFIX}"

export NJ="-j$(nproc)"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if [ "${GCC_DBG}" == "y" ]; then

    echo ""
    echo ">>> GCC Serch Dirs"
    echo "    LDFLAGS  = ${LDFLAGS}"
    echo "    CPPFLAGS = ${CPPFLAGS}"
    ${SDK_PATH_NATIVE}/bin/arm-linux-gnueabihf-g++ --version
    ${SDK_PATH_NATIVE}/bin/arm-linux-gnueabihf-g++ -print-search-dirs
    echo ""

    exit 1
fi
