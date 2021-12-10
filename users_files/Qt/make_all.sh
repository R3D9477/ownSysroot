#!/bin/bash

source "set_env.sh"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if ! ( bash binbck_install.sh ) ; then
    if ! ( bash get.sh )                ; then goto_exit 1  ; fi
    if ! ( run_patcher "${Qt_PATCH}" )  ; then goto_exit 2  ; fi
    if ! ( bash make_qt_base.sh )       ; then goto_exit 3  ; fi
    if ! ( bash make_qt_quick.sh )      ; then goto_exit 4  ; fi
    if ! ( bash make_qt_multimedia.sh ) ; then goto_exit 5  ; fi
    if ! ( bash make_qt_serialport.sh ) ; then goto_exit 6  ; fi
    if ! ( bash install_fonts.sh )      ; then goto_exit 7  ; fi
    if ! ( bash export.sh )             ; then goto_exit 8  ; fi
    if ! ( bash deploy2sysroot.sh )     ; then goto_exit 9  ; fi
    if ! ( bash binbck_create.sh )      ; then goto_exit 10 ; fi
fi

if ! ( bash ld_reg_qt_libs.sh ) ; then goto_exit 11 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

show_message "Qt ${Qt_VER} was sucessfully installed"
