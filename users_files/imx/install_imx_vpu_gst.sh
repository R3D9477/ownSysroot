#!/bin/bash

IMX_FIRMWARE="firmware-imx-7.5" #"firmware-imx-5.4"
IMX_VPU="imx-vpu-5.4.38" #"imx-vpu-5.4.31"
IMX_CODEC="imx-codec-4.3.5" #"libfslcodec-4.0.7"

IMX_DMABUFFER_BRANCH="master"
IMX_DMABUFFER_REVISION=
IMX_VPUAPI_BRANCH="master" #"v1"
IMX_VPUAPI_REVISION="4afb52f97e28c731c903a8538bf99e4a6d155b42" #
IMX_GSTREAMER_BRANCH="master"
IMX_GSTERANER_REVISION="889b8352ca09cd224be6a2f8d53efd59a38fa9cb" #
IMX_EGL="fb"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if ! ( preAuthRoot && sudo mkdir -p "$SYSROOT/usr/src/imx" ) ; then exit 1 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

function get_bin_pkg() {

    if ! [ -d "$1" ] ; then
        wget -nc -O "$1.bin" "http://www.freescale.com/lgfiles/NMG/MAD/YOCTO/$1.bin"
        chmod +x "$1.bin"
        if ! ( ./"$1.bin" --force --auto-accept ) ; then exit 1 ; fi
    fi

    if ! ( preAuthRoot && sudo cp -R "$1" "$SYSROOT/usr/src/imx/" ) ; then exit 2 ; fi
}

function get_git_pkg() {

    if ! [ -d "$1-$2" ] ; then
        if [ -f "$1-$2.tar" ] ; then
            if ! tar -xf "$1-$2.tar" ; then exit 3 ; fi
        else
            if ! git clone -b "$2" --single-branch "https://github.com/Freescale/$1.git" "$1-$2" ; then exit 4 ; fi
            if ! tar -cf "$1-$2.tar" "$1-$2" ; then exit 5 ; fi
        fi
    fi

    if ! [ -z "$3" ] ; then
        pushd "$1-$2"
            if ! ( git reset --hard "$3" ) ; then exit 6 ; fi
        popd
    fi

    if ! ( preAuthRoot && sudo cp -R "$1-$2" "$SYSROOT/usr/src/imx/" ) ; then exit 7 ; fi
}

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if ! pushd "$CACHE" ; then exit 1 ; fi

    get_bin_pkg "$IMX_FIRMWARE"
    get_bin_pkg "$IMX_VPU"
    get_bin_pkg "$IMX_CODEC"

    get_git_pkg "libimxdmabuffer"   "$IMX_DMABUFFER_BRANCH"     "$IMX_DMABUFFER_REVISION"
    get_git_pkg "libimxvpuapi"      "$IMX_VPUAPI_BRANCH"        "$IMX_VPUAPI_REVISION"
    get_git_pkg "gstreamer-imx"     "$IMX_GSTREAMER_BRANCH"     "$IMX_GSTERANER_REVISION"

    #--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    # IMX FIRMWARE

    preAuthRoot && sudo cp -R --remove-destination "$IMX_FIRMWARE/firmware" "$SYSROOT/lib/"
    preAuthRoot && sudo chroot "$SYSROOT" chmod -R +x "/lib/firmware"

    #--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---
    # IMX VPU, GST

    if ! pushd "$SYSROOT/usr/src/imx" ; then exit 1 ; fi

        preAuthRoot && echo "#!/bin/bash

function run_cmd() { if ! eval \$@ ; then echo \">>> command \$@ was failed\" ; exit 1 ; fi }

pushd /usr/src/imx

    rm .install_success

    pushd $IMX_VPU
        run_cmd make PLATFORM=IMX6Q INCLUDE='-I/include/uapi -I/include -I/usr/include -I/usr/include/uapi' all
        run_cmd make PLATFORM=IMX6Q install
    popd

    echo ''
    echo '>>> install imx_codec'
    echo ''

    pushd $IMX_CODEC
        run_cmd ./autogen.sh --prefix=/usr --enable-fhw --enable-vpu
        run_cmd make all
        run_cmd make install
        run_cmd mv /usr/lib/imx-mm/video-codec/* /usr/lib/
        run_cmd mv /usr/lib/imx-mm/audio-codec/* /usr/lib/
        run_cmd rm -rf /usr/lib/imx-mm/
    popd

    sync; sleep 1

    echo ''
    echo '>>> install imx_dmabuffer'
    echo ''

    pushd libimxdmabuffer-$IMX_DMABUFFER_BRANCH
        run_cmd ./waf configure --prefix=/usr --includedir=/usr/include  --imx-linux-headers-path=/include --with-ipu-allocator=yes --with-g2d-allocator=yes
        run_cmd ./waf
        run_cmd ./waf install
    popd

    echo ''
    echo '>>> install imx_vpuapi'
    echo ''

    pushd libimxvpuapi-$IMX_VPUAPI_BRANCH
        if [[ \"\$PWD\" =~ \"v2\" ]] ; then
            run_cmd ./waf configure --prefix=/usr --sysroot-path=/ --imx-headers=/include --imx-platform=imx6
        else
            run_cmd ./waf configure --prefix=/usr --includedir=/usr/include
        fi
        run_cmd ./waf
        run_cmd ./waf install
    popd

    echo ''
    echo '>>> install imx_gstreamer'
    echo ''

    pushd gstreamer-imx-$IMX_GSTREAMER_BRANCH

        rm -rf /usr/lib/gstreamer-1.0
        run_cmd ln -s /usr/lib/arm-linux-gnueabihf/gstreamer-1.0 /usr/lib/gstreamer-1.0

        export CFLAGS=-I/usr/include
        export LDFLAGS=-L/usr/lib/arm-linux-gnueabihf

        if [[ \"\$PWD\" =~ \"v2\" ]] ; then
            run_cmd mkdir build
            pushd build
                run_cmd meson .. -Dprefix=/usr
                run_cmd ninja install
            popd
        else
            run_cmd ./waf configure --prefix=/usr --kernel-headers=/include --g2d-includes=/usr/include --egl-platform=$IMX_EGL
            run_cmd ./waf
            run_cmd ./waf install
        fi

        mv /usr/lib/libgstimx* /usr/lib/arm-linux-gnueabihf/
        mv /usr/lib/gstreamer-1.0/libgstimx* /usr/lib/arm-linux-gnueabihf/gstreamer-1.0/
        rmdir /usr/lib/gstreamer-1.0
    popd

    echo ''
    gst-inspect-1.0 | grep imx
    echo ''

    GST_V4L2_CHK=\$(gst-inspect-1.0 | grep imxv4l2)
    if [ -z \"\$GST_V4L2_CHK\" ] ; then
        echo ''
        echo '>>> gstreamer-imx: V4L2 is not found'
        echo ''
        exit 1
    fi

    sync

    echo 1 > .install_success
popd

exit 0" | sudo tee "install.sh"

        preAuthRoot && sudo chroot "$SYSROOT" chmod +x "/usr/src/imx/install.sh"
        preAuthRoot && sudo chroot "$SYSROOT" "/usr/src/imx/install.sh"
        if ! [ -f "$SYSROOT/usr/src/imx/.install_success" ] ; then exit 1 ; fi

    popd

popd

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

echo "IMX VPU AND GST WERE SUCCESSFULLY INSTALLED!"

exit 0
