#!/bin/bash

BRANCH="master"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

CORE_CACHE="$CACHE"
export CACHE=$(realpath -s -m "$CORE_CACHE/QtMakerCache")

mkdir -p "$CACHE"

if [ -z "$Qt_TC_URL" ] ; then
    export Qt_TC_URL="https://releases.linaro.org/components/toolchain/binaries/latest-7/arm-linux-gnueabihf/gcc-linaro-7.5.0-2019.12-x86_64_arm-linux-gnueabihf.tar.xz"
fi

export TC_URL="$Qt_TC_URL"

source "$COREDIR/01-set_tc.sh"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if ! pushd "$CORE_CACHE" ; then exit 1 ; fi

    if ! [ -d "QtMaker-$BRANCH" ] ; then
        if [ -f "QtMaker-$BRANCH.tar" ] ; then
            if ! tar -xf "QtMaker-$BRANCH.tar" ; then exit 2 ; fi
        else
            if ! git clone -b "$BRANCH" --single-branch "https://github.com/r3d9u11/QtMaker.git" "QtMaker-$BRANCH" ; then exit 3 ; fi
            if ! tar -cf "QtMaker-$BRANCH.tar" "QtMaker-$BRANCH" ; then exit 4 ; fi
        fi
    fi

popd

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

function link2host() {

    if ! [ -L "$1.device_link" ] ; then

        if ( preAuthRoot && sudo mv "$1" "$1.device_link" ) ; then
            if ( preAuthRoot && sudo ln -s "$SYSROOT"$(readlink "$1.device_link") "$1" ) ; then
                preAuthRoot && sudo chmod +r "$1"
                return 0
            fi
        fi

        return 1;
    fi

    return 0
}

function link2device() {

    if [ -L "$1.device_link" ] ; then

        preAuthRoot && sudo rm "$1"
        if ( preAuthRoot && sudo mv "$1.device_link" "$1" ) ; then return 0 ; fi

        return 1
    fi

    return 0
}

function transformLink() {

    echo ">>>     TRANSFORM LINK ($2): $1"

    if [ -L "$1" ]; then
        TRGPATH=$(readlink "$1")
        if [ "${TRGPATH:0:1}" == '/' ] && [ "$TRGPATH" != "$SYSROOT"* ]; then
            if [ "$2" == "device" ] ; then
                link2device "$1"
                transformLink "$(readlink $1)" "device"
            elif [ "$2" == "host" ] ; then
                link2host "$1"
                transformLink "$(readlink $1)" "host"
            fi
        fi
    fi

    return 0
}

function transformDir() {

    echo ""
    echo ">>> TRANSFORM DIR ($1): $2"
    echo ""

    if [ -z "$3" ] ; then
        for OBJPATH in "$2"/* ; do transformLink "$OBJPATH" "$1" ; done
    else
        transformLink "$2"/"$3" "$1"
    fi

    return 0
}

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

transformDir "host" "$SYSROOT/usr/lib/arm-linux-gnueabihf/pkgconfig"
transformDir "host" "$SYSROOT/usr/lib/arm-linux-gnueabihf" "libm.so"
transformDir "host" "$SYSROOT/usr/lib/arm-linux-gnueabihf" "libdl.so"
transformDir "host" "$SYSROOT/usr/lib/arm-linux-gnueabihf" "libpthread.so"
transformDir "host" "$SYSROOT/usr/lib/arm-linux-gnueabihf" "libglib-2.0.so"

pushd "$CORE_CACHE/QtMaker-$BRANCH"
    if ! bash "make-all.sh" ; then exit 5 ; fi
popd

transformDir "device" "$SYSROOT/usr/lib/arm-linux-gnueabihf/pkgconfig"
transformDir "device" "$SYSROOT/usr/lib/arm-linux-gnueabihf" "libm.so"
transformDir "device" "$SYSROOT/usr/lib/arm-linux-gnueabihf" "libdl.so"
transformDir "device" "$SYSROOT/usr/lib/arm-linux-gnueabihf" "libpthread.so"
transformDir "device" "$SYSROOT/usr/lib/arm-linux-gnueabihf" "libglib-2.0.so"
