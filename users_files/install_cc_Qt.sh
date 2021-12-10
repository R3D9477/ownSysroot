#!/bin/bash
show_current_task

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

transformFsToHost
pushd "${USERDIR}/Qt"

    CORE_CACHE="${CACHE}"
    export CACHE=$(realpath -s -m "${CORE_CACHE}/QtCache")  # OVERRIDE DESTINACTION CACHE DIRECTORY
    mkdir -p "${CACHE}"

    source "set_env.sh"

    export TC_URL="${Qt_TC_URL}"                            # OVERRIDE TOOLCHAIN

    source "${COREDIR}/01-set_tc.sh"

    if ! bash "make_all.sh" ; then goto_exit 1 ; fi
    
popd
transformFsToDevice
