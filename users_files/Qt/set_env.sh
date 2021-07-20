exportdefvar Qt_TC_URL          "https://releases.linaro.org/components/toolchain/binaries/latest-7/arm-linux-gnueabihf/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz"

exportdefvar Qt_GITURL          "git://code.qt.io/qt"
exportdefvar Qt_VER             "5.15"
exportdefvar Qt_DIR             "/opt/Qt${Qt_VER}"

exportdefvar Qt_DEVICE          "generic"
exportdefvar Qt_ARCH            "$(uname -i)"

exportdefvar Qt_OPENSOURCE      y
exportdefvar Qt_LICENSE         "opensource"
exportdefvar Qt_ACCEPT_CONFIG   a
exportdefvar Qt_RECOMPILE       y

exportdefvar Qt_INSTALL_QML     y
exportdefvar Qt_INSTALL_MM      y
exportdefvar Qt_INSTALL_SERIAL  y

exportdefvar Qt_MAKE_BINBCK     y
exportdefvar Qt_INSTALL_BINBCK  y
exportdefvar Qt_BINBCK          "${CACHE}/Qt${Qt_VER}_${Qt_DEVICE}-${Qt_ARCH}_BINBCK"

exportdefvar Qt_TEST            "$(realpath -s 'test')"
exportdefvar Qt_EXPORT          "${CACHE}/qtest_$(date '+%Y%m%d%H%M%S')"

exportdefvar Qt_MAKESCRIPT      "qt_make_full.sh"

if ( [[ "${Qt_ARCH}" =~ "arm" ]] || [[ "${Qt_ARCH}" =~ "aarch" ]] ) ; then  exportdefvar Qt_OPENGL   "es2"
elif [[ "${Qt_ARCH}" =~ "x86" ]] ; then                                     exportdefvar Qt_OPENGL   "desktop"
else                                                                        exportdefvar Qt_OPENGL   "dynamic"
fi

export CFLAGS="-Ofast --sysroot=${SYSROOT} -march=${mARCH} -I${SYSROOT}/include -I${SYSROOT}${HOST_PREFIX}/include"
export CPPFLAGS="${CFLAGS}"
export CXXFLAGS="${CFLAGS}"

export LDFLAGS="${LDFLAGS} -Bsymbolic-functions --hash-style=gnu"
