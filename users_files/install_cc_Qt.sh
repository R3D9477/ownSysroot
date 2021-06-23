#!/bin/bash
show_current_task

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

CORE_CACHE="${CACHE}"
export CACHE=$(realpath -s -m "$CORE_CACHE/QtCache")    # OVERRIDE DESTINACTION CACHE DIRECTORY
mkdir -p "${CACHE}"

export TC_URL="$Qt_TC_URL"                              # OVERRIDE TOOLCHAIN

source "${COREDIR}/01-set_tc.sh"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

transformFsToHost

pushd "${USERDIR}/Qt"
    if ! bash "make_all.sh" ; then goto_exit 1 ; fi
popd

transformFsToDevice
