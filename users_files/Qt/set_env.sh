
exportdefvar Qt_TC_URL              "https://releases.linaro.org/components/toolchain/binaries/latest-7/arm-linux-gnueabihf/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz"

exportdefvar Qt_GENERATE_MESON_INI  y

exportdefvar Qt_GITURL              "git://code.qt.io/qt"
exportdefvar Qt_VER                 "5.15"
exportdefvar Qt_DIR                 "/opt/Qt${Qt_VER}"

exportdefvar Qt_DEVICE              "generic"
exportdefvar Qt_ARCH                "$(uname -i)"

exportdefvar Qt_OPENSOURCE          y
exportdefvar Qt_LICENSE             "opensource"
exportdefvar Qt_ACCEPT_CONFIG       a
exportdefvar Qt_RECOMPILE           y

exportdefvar Qt_INSTALL_BASE        y
exportdefvar Qt_INSTALL_QML         y
exportdefvar Qt_INSTALL_MM          y
exportdefvar Qt_INSTALL_SERIAL      y

exportdefvar Qt_MAKE_BINBCK         y
exportdefvar Qt_INSTALL_BINBCK      y
exportdefvar Qt_BINBCK              "${CACHE}/Qt${Qt_VER}_${Qt_DEVICE}-${Qt_ARCH}_BINBCK"

exportdefvar Qt_TEST                "$(realpath -s 'test')"
exportdefvar Qt_EXPORT              "${CACHE}/qtest_$(date '+%Y%m%d%H%M%S')"

exportdefvar Qt_USE_CCOPT           y

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if ( [[ "${Qt_ARCH}" =~ "arm" ]] || [[ "${Qt_ARCH}" =~ "aarch" ]] ) ; then  exportdefvar Qt_OPENGL   "es2"
elif [[ "${Qt_ARCH}" =~ "x86" ]] ; then                                     exportdefvar Qt_OPENGL   "desktop"
else                                                                        exportdefvar Qt_OPENGL   "dynamic"
fi

if [[ "${Qt_USE_CCOPT}" == "y" ]] ; then
    export CFLAGS=" -Ofast --sysroot=${SYSROOT} -march=${mARCH} -I${SYSROOT}/include -I${SYSROOT}${HOST_PREFIX}/include"
    export CPPFLAGS="${CFLAGS}"
    export CXXFLAGS="${CFLAGS}"
    export LDFLAGS="${LDFLAGS} -Bsymbolic-functions --hash-style=gnu"
fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if [ "${Qt_GENERATE_MESON_INI}" == "y" ]; then

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
qmake = '${SYSROOT}${Qt_DIR}/bin/qmake'
moc   = '${SYSROOT}${Qt_DIR}/bin/moc'
uic   = '${SYSROOT}${Qt_DIR}/bin/uic'
rcc   = '${SYSROOT}${Qt_DIR}/bin/rcc'

[properties]
root = '${SYSROOT}'
sys_root = '${SYSROOT}'
pkg_config_libdir = [ '${SYSROOT}${HOST_PREFIX}/lib/pkgconfig', '${SYSROOT}${HOST_PREFIX}${HOST_LIBDIR}/pkgconfig', '${SYSROOT}${Qt_DIR}/lib/pkgconfig' ]
c_args = [ '--sysroot=${SYSROOT}' ]
cpp_args = [ '--sysroot=${SYSROOT}' ]
link_args = [ '--sysroot=${SYSROOT}', '-Wl,-rpath-link,${SYSROOT}/lib/${TOOLCHAIN_SYS}', '-Wl,-rpath-link,${SYSROOT}${HOST_PREFIX}${HOST_LIBDIR}', '-Wl,-rpath-link,${SYSROOT}${Qt_DIR}/lib' ]" | tee "${MESON_INI_FILE}"

fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

function mk_inst() {

    show_message "MAKE+INSTALL: $1-${Qt_VER}"

    ERR=1

    if pushd "${CACHE}/$1-${Qt_VER}" ; then

        if ( [ "${Qt_RECOMPILE}" != "n" ] || ! [ -f ".made" ] ) ; then

            if   [ -f "./autogen.sh" ] ; then CFG="./autogen.sh"
            elif [ -f "./configure"  ] ; then CFG="./configure"
            else CFG="${SYSROOT}${Qt_DIR}/bin/qmake"
            fi

            if [[ "${PWD}" =~ "qt" ]] ; then
                preAuthRoot && sudo rm ".made"
                preAuthRoot && sudo rm "config.log"
                preAuthRoot && sudo rm "config.cache"
                preAuthRoot && sudo rm -rf "lib"
                preAuthRoot && sudo rm -rf "plugins"
            fi

            if ( preAuthRoot && sudo ${CFG} ${@:2} ) ; then

                unset Qt_AC

                if ( [ "${Qt_ACCEPT_CONFIG}" == "y" ] || [ "${Qt_ACCEPT_CONFIG}" == "n" ] ) ; then
                    Qt_AC="${Qt_ACCEPT_CONFIG}"
                else
                    read -p "ACCEPT Qt CONFIG? (y/Y/n): " Qt_AC
                    if [ "${Qt_AC}" == "Y" ] ; then export Qt_ACCEPT_CONFIG="y" ; fi
                fi

                if ( ( [ "${Qt_AC}" == "y" ] || [ "${Qt_AC}" == "Y" ] ) && [[ "${PWD}" =~ "qt" ]] ) ; then
                    if ( preAuthRoot && sudo make ${NJ} ) ; then echo "1" > ".made" ; fi
                fi
            fi
        fi

        if [ -f ".made" ] ; then
            preAuthRoot && sudo make install
            ERR=0
        fi

        popd
    fi

    if [ $ERR != "0" ] ; then
        show_message "UNABLE TO COMPILE AND(OR) INSTALL $1"
    fi

    return ${ERR}
}
