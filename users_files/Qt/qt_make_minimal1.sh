#!/bin/bash

source "set_env.sh"

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

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

pushd "${CACHE}"

    if ( [ "${Qt_DEVICE}" == "imx6" ] || [ "${Qt_DEVICE}" == "linux-imx6-g++" ] ) ; then

        imx6_MKS_DIR="${CACHE}/qtbase-${Qt_VER}/mkspecs/devices/linux-imx6-g++"

        if ! [ -f "${imx6_MKS_DIR}/imx6-qmake.conf" ] ; then

            echo "FIX: imx6_qmake.conf"

            mv "${imx6_MKS_DIR}/qmake.conf" "${imx6_MKS_DIR}/imx6-qmake.conf"

            echo "include(imx6-qmake.conf)" > "${imx6_MKS_DIR}/qmake.conf"

            echo "QMAKE_RPATHDIR += ${SYSROOT}/lib/arm-linux-gnueabihf"     >> "${imx6_MKS_DIR}/qmake.conf"
            echo "QMAKE_RPATHDIR += ${SYSROOT}/usr/lib/arm-linux-gnueabihf" >> "${imx6_MKS_DIR}/qmake.conf"
        fi
    fi

    if ! mk_inst qtbase                                     \
        -${Qt_LICENSE} -confirm-license                     \
        -device "${Qt_DEVICE}"                              \
        -device-option CROSS_COMPILE="${TOOLCHAIN_PREFIX}"  \
        -sysroot "${SYSROOT}"                               \
        -prefix "${Qt_DIR}"                                 \
        -opengl "${Qt_OPENGL}"                              \
        -rpath                                              \
        -release                                            \
        -recheck                                            \
        -silent                                             \
        -qt-zlib                                            \
        -ltcg                                               \
        -strip                                              \
        -make   libs                                        \
        -nomake tools                                       \
        -nomake tests                                       \
        -nomake examples                                    \
        -no-use-gold-linker                                 \
        -skip qt3d                          \
        -skip qtandroidextras               \
        -skip qtcanvas3d                    \
        -skip qtcharts                      \
        -skip qtconnectivity                \
        -skip qtdatavis3d                   \
        -skip qtdeclarative                 \
        -skip qtdoc                         \
        -skip qtgamepad                     \
        -skip qtgraphicaleffects            \
        -skip qtimageformats                \
        -skip qtlocation                    \
        -skip qtmacextras                   \
        -skip qtmultimedia                  \
        -skip qtnetworkauth                 \
        -skip qtpurchasing                  \
        -skip qtquickcontrols               \
        -skip qtquickcontrols2              \
        -skip qtscript                      \
        -skip qtscxml                       \
        -skip qtsensors                     \
        -skip qtserialbus                   \
        -skip qtserialport                  \
        -skip qtspeech                      \
        -skip qtsvg                         \
        -skip qttools                       \
        -skip qttranslations                \
        -skip qtvirtualkeyboard             \
        -skip qtwayland                     \
        -skip qtwebchannel                  \
        -skip qtwebengine                   \
        -skip qtwebsockets                  \
        -skip qtwebview                     \
        -skip qtwinextras                   \
        -skip qtx11extras                   \
        -skip qtxmlpatterns                 \
        -no-feature-texthtmlparser          \
        -no-feature-textodfwriter           \
        -no-feature-concurrent              \
        -no-feature-effects                 \
        -no-feature-sharedmemory            \
        -no-feature-systemsemaphore         \
        -no-feature-im                      \
        -no-feature-process                 \
        -no-feature-dom                     \
        -no-feature-filesystemmodel         \
        -no-feature-filesystemwatcher       \
        -no-feature-graphicsview            \
        -no-feature-graphicseffect          \
        -no-feature-sizegrip                \
        -no-feature-calendarwidget          \
        -no-feature-printpreviewwidget      \
        -no-feature-keysequenceedit         \
        -no-feature-colordialog             \
        -no-feature-filedialog              \
        -no-feature-fontdialog              \
        -no-feature-printpreviewdialog      \
        -no-feature-progressdialog          \
        -no-feature-inputdialog             \
        -no-feature-errormessage            \
        -no-feature-wizard                  \
        -no-feature-datawidgetmapper        \
        -no-feature-imageformat_bmp         \
        -no-feature-imageformat_ppm         \
        -no-feature-imageformat_xbm         \
        -no-feature-imageformat_png         \
        -no-feature-imageformat_jpeg        \
        -no-feature-image_heuristic_mask    \
        -no-feature-image_text              \
        -no-feature-colornames              \
        -no-feature-cups                    \
        -no-feature-paint_debug             \
        -no-feature-freetype                \
        -no-feature-translation             \
        -no-feature-codecs                  \
        -no-feature-big_codecs              \
        -no-feature-iconv                   \
        -no-feature-ftp                     \
        -no-feature-udpsocket               \
        -no-feature-networkproxy            \
        -no-feature-socks5                  \
        -no-feature-networkdiskcache        \
        -no-feature-bearermanagement        \
        -no-feature-completer               \
        -no-feature-fscompleter             \
        -no-feature-desktopservices         \
        -no-feature-mimetype                \
        -no-feature-systemtrayicon          \
        -no-feature-undocommand             \
        -no-feature-undostack               \
        -no-feature-undogroup               \
        -no-feature-undoview                \
        -no-feature-statemachine            \
        -no-feature-gestures                \
        -no-feature-dbus                    \
    ; then
        goto_exit 1; fi

    if [ "${Qt_INSTALL_QML}" == "y" ] ; then
        if ! mk_inst qtdeclarative ; then goto_exit 2; fi
        if ! mk_inst qtquickcontrols2 ; then goto_exit 3; fi
    fi
    
    if [ "${Qt_INSTALL_MM}" == "y" ] ; then
        if ! mk_inst qtmultimedia ; then goto_exit 4; fi
    fi

    if [ "${Qt_INSTALL_SERIAL}" == "y" ] ; then
        if ! mk_inst qtserialport ; then goto_exit 5; fi
    fi

    preAuthRoot && sudo chmod -R +r "${SYSROOT}${Qt_DIR}"

popd

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

show_message "Qt ${Qt_VER} libs were successfully built"
