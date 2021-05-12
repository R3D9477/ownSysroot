#!/bin/bash

if ! pushd "${CACHE}" ; then goto_exit 1 ; fi

    if ! [ -d "dejavu-fonts-ttf-2.37" ] ; then

        wget -nc -O "dejavu-fonts-ttf-2.37.tar.bz2" "https://sourceforge.net/projects/dejavu/files/dejavu/2.37/dejavu-fonts-ttf-2.37.tar.bz2/download"

        if ! ( tar xjf "dejavu-fonts-ttf-2.37.tar.bz2" ) ; then

            show_message "UNABLE TO DOWNLOAD FONTS"
            goto_exit 2
        fi
    fi

    if ! [ -d "${SYSROOT}${Qt_DIR}/lib/fonts" ] ; then

        if ! ( preAuthRoot && sudo mkdir "${SYSROOT}${Qt_DIR}/lib/fonts" ) ; then

            show_message "UNABLE TO CREATE DESTINATION DIRECTORY"
            goto_exit 3
        fi
    fi

    if ! ( preAuthRoot && sudo cp "dejavu-fonts-ttf-2.37/ttf/"* "${SYSROOT}${Qt_DIR}/lib/fonts/" ) ; then

        show_message "UNABLE TO INSTALL FONTS"
        goto_exit 4
    fi
