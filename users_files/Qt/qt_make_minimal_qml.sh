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
        -rpath                                              \
        -no-use-gold-linker                                 \
        -release                                            \
        -recheck                                            \
        -silent                                             \
        -nomake tests                                       \
        -nomake examples                                    \
        -qt-zlib                                            \
        -ltcg                                               \
        -skip qtconnectivity                                \
        -no-feature-getentropy                              \
        -strip                              \
        -no-journald                        \
        -no-syslog                          \
        -no-slog2                           \
        -no-widgets                         \
        -no-openssl                         \
        -no-xcb                             \
        -no-xcb-xlib                        \
        -no-libudev                         \
        -no-evdev                           \
        -no-imf                             \
        -no-libinput                        \
        -no-mtdev                           \
        -no-tslib                           \
        -no-bundled-xcb-xinput              \
        -no-xkbcommon                       \
        -no-cups                            \
        -no-iconv                           \
        -no-libproxy                        \
        -no-system-proxies                  \
        -no-kms                             \
        -no-direct2d                        \
        -no-gbm                             \
        -no-directfb                        \
        -no-icu                             \
        -no-ico                             \
        -no-libjpeg                         \
        -no-gtk                             \
        -no-feature-buttongroup             \
        -no-feature-calendarwidget          \
        -no-feature-checkbox                \
        -no-feature-abstractbutton          \
        -no-feature-abstractslider          \
        -no-feature-combobox                \
        -no-feature-commandlinkbutton       \
        -no-feature-contextmenu             \
        -no-feature-datetimeedit            \
        -no-feature-dial                    \
        -no-feature-dockwidget              \
        -no-feature-fontcombobox            \
        -no-feature-formlayout              \
        -no-feature-graphicseffect          \
        -no-feature-graphicsview            \
        -no-feature-groupbox                \
        -no-feature-keysequenceedit         \
        -no-feature-label                   \
        -no-feature-lcdnumber               \
        -no-feature-lineedit                \
        -no-feature-listwidget              \
        -no-feature-mainwindow              \
        -no-feature-mdiarea                 \
        -no-feature-menu                    \
        -no-feature-menubar                 \
        -no-feature-pushbutton              \
        -no-feature-radiobutton             \
        -no-feature-progressbar             \
        -no-feature-printpreviewwidget      \
        -no-feature-resizehandler           \
        -no-feature-rubberband              \
        -no-feature-scrollarea              \
        -no-feature-scrollbar               \
        -no-feature-scroller                \
        -no-feature-toolbar                 \
        -no-feature-toolbox                 \
        -no-feature-toolbutton              \
        -no-feature-tooltip                 \
        -no-feature-stackedwidget           \
        -no-feature-spinbox                 \
        -no-feature-splashscreen            \
        -no-feature-splitter                \
        -no-feature-sizegrip                \
        -no-feature-slider                  \
        -no-feature-statusbar               \
        -no-feature-statustip               \
        -no-feature-tabbar                  \
        -no-feature-validator               \
        -no-feature-treewidget              \
        -no-feature-textedit                \
        -no-feature-textbrowser             \
        -no-feature-syntaxhighlighter       \
        -no-feature-tablewidget             \
        -no-feature-tabwidget               \
        -no-feature-widgettextcontrol       \
        -no-feature-whatsthis               \
        -no-feature-wizard                  \
        -no-feature-colordialog             \
        -no-feature-dialog                  \
        -no-feature-dialogbuttonbox         \
        -no-feature-errormessage            \
        -no-feature-filedialog              \
        -no-feature-fontdialog              \
        -no-feature-inputdialog             \
        -no-feature-messagebox              \
        -no-feature-printpreviewdialog      \
        -no-feature-printdialog             \
        -no-feature-progressdialog          \
        -no-feature-action                  \
        -no-feature-clipboard               \
        -no-feature-cursor                  \
        -no-feature-highdpiscaling          \
        -no-feature-texthtmlparser          \
        -no-feature-textmarkdownreader      \
        -no-feature-textmarkdownwriter      \
        -no-feature-textodfwriter           \
        -no-feature-im                      \
        -no-feature-tabletevent             \
        -no-feature-shortcut                \
        -no-feature-image_heuristic_mask    \
        -no-feature-image_text              \
        -no-feature-imageformat_bmp         \
        -no-feature-imageformat_jpeg        \
        -no-feature-imageformat_ppm         \
        -no-feature-imageformat_xbm         \
        -no-feature-imageformat_xpm         \
        -no-feature-imageformatplugin       \
        -no-feature-movie                   \
        -no-feature-fscompleter             \
        -no-feature-gestures                \
        -no-feature-hijricalendar           \
        -no-feature-islamiccivilcalendar    \
        -no-feature-jalalicalendar          \
        -no-feature-mimetype                \
        -no-feature-tuiotouch               \
        -no-feature-valgrind                \
        -no-feature-sqlmodel                \
        -no-feature-systemtrayicon          \
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
