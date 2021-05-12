#!/bin/bash

source "set_env.sh"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if ! ( get_git_pkg "${Qt_GITURL}" "qtbase" "${Qt_VER}" ) ; then goto_exit 1 ; fi
if ! ( get_git_pkg "${Qt_GITURL}" "qtmultimedia" "${Qt_VER}" ) ; then goto_exit 2 ; fi
if ! ( get_git_pkg "${Qt_GITURL}" "qtdeclarative" "${Qt_VER}" ) ; then goto_exit 3 ; fi
if ! ( get_git_pkg "${Qt_GITURL}" "qtquickcontrols2" "${Qt_VER}" ) ; then goto_exit 4 ; fi
if ! ( get_git_pkg "${Qt_GITURL}" "qtserialport" "${Qt_VER}" ) ; then goto_exit 5 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

show_message "QtMaker: Qt $Qt_VER libs were sucessfully got"
