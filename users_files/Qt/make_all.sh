#!/bin/bash

source "set_env.sh"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if ! ( bash binbck_install.sh ) ; then
    if ! ( bash get.sh )                ; then goto_exit 1 ; fi
    if ! ( bash make.sh )               ; then goto_exit 2 ; fi
    if ! ( bash install_fonts.sh )      ; then goto_exit 3 ; fi
    if ! ( bash export.sh )             ; then goto_exit 4 ; fi
    if ! ( bash deploy2sysroot.sh )     ; then goto_exit 5 ; fi
    if ! ( bash binbck_create.sh )      ; then goto_exit 6 ; fi
fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

show_message "Qt ${Qt_VER} was sucessfully installed"
