#!/bin/bash

APPDIR="$(dirname "$(realpath -s "$0")")"
Qt_DIR=$(realpath -s "${APPDIR}/..")

export LD_LIBRARY_PATH="${Qt_DIR}/lib"

export QT_QPA_PLATFORM_PLUGIN_PATH="${Qt_DIR}/plugins"
export QT_QPA_PLATFORM="eglfs"

if [ "$1" == "debug" ] ; then
    export QT_QPA_DEBUG=1
    export QT_LOGGING_RULES="qt.qpa.*=true"
    exec   $(${APPDIR}/$(basename $0 | sed s,\.sh$,,))
else
    export QT_QPA_DEBUG=0
    exec   $(${APPDIR}/$(basename $0 | sed s,\.sh$,,)) > /dev/null 2>&1
fi
