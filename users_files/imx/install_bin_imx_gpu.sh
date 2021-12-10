#!/bin/bash
show_current_task

exportdefvar IMX_GPU_VIV        "imx-gpu-viv-5.0.11.p8.6-hfp" #"imx-gpu-viv-5.0.11.p8.3-hfp" #"imx-gpu-viv-6.4.3.p1.2-aarch32"
exportdefvar IMX_GPU_G2D        "imx-gpu-viv-5.0.11.p8.6-hfp" #"imx-gpu-viv-5.0.11.p8.3-hfp" #"imx-gpu-g2d-6.4.3.p1.2-arm"

exportdefvar IMX_GPU_VIV_PATCH  "${USERDIR}/imx/patch_gpu_viv.sh"
exportdefvar IMX_GPU_G2D_PATCH  ""

exportdefvar IMX_EGL            "fb"

exportdefvar IMX_BIN_URL        "http://www.freescale.com/lgfiles/NMG/MAD/YOCTO"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# GET PACKAGES --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if ! ( get_bin_pkg "${IMX_BIN_URL}" "${IMX_GPU_VIV}" ) ; then goto_exit 1 ; fi
if ! ( get_bin_pkg "${IMX_BIN_URL}" "${IMX_GPU_G2D}" ) ; then goto_exit 1 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# INSTALL PACKAGES - --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

function set_lib_backend() {
    
    SRC_LIB_NAME="$1"
    
    unset SRC_LIB_FILE
    if ! [ -f "${SRC_LIB_FILE}" ] ; then SRC_LIB_FILE="${IMX_EGL}/${SRC_LIB_NAME}.so" ; fi
    if ! [ -f "${SRC_LIB_FILE}" ] ; then SRC_LIB_FILE="${SRC_LIB_NAME}-${IMX_EGL}.so" ; fi
    
    if [ -f "${SRC_LIB_FILE}" ]
    then
        rm ${1}.so*
        ln -s "${SRC_LIB_FILE}"    "$1.so"
        ln -s "${SRC_LIB_FILE}"    "$1.so.1"
        ln -s "${SRC_LIB_FILE}"    "$1.so.1.0"
        ln -s "${SRC_LIB_FILE}"    "$1.so.1.0.0"
        ln -s "${SRC_LIB_FILE}"    "$1.so.2"
        ln -s "${SRC_LIB_FILE}"    "$1.so.2.0"
        ln -s "${SRC_LIB_FILE}"    "$1.so.2.0.0"
    else
        show_message "i.MX6 G2D WARN: LIBRARY ${SRC_LIB_FILE} DOESN'T EXIST!"
    fi
}

if ! pushd "${CACHE}" ; then goto_exit 2 ; fi

    if ! ( run_patcher "${IMX_GPU_VIV_PATCH}" ) ; then goto_exit 3 ; fi
    if ! ( run_patcher "${IMX_GPU_G2D_PATCH}" ) ; then goto_exit 3 ; fi
    
    if ! pushd "${IMX_GPU_VIV}/gpu-core/usr" ; then goto_exit 4 ; fi
    
        # IMX GPU

        if ! pushd "lib" ; then goto_exit 5 ; fi
            if [ -d "${IMX_EGL}" ]
            then
                cp -f -d "${IMX_EGL}"/* ./
            else
                set_lib_backend "libEGL"
                set_lib_backend "libGAL"
                set_lib_backend "libGLESv2"
                set_lib_backend "libVIVANTE"
            fi
        popd

        if ! pushd "include" ; then goto_exit 6 ; fi
            sed -i 's|libdir=/usr/lib|libdir=/usr/lib/arm-linux-gnueabihf|g' *.pc
        popd
    popd

    #if ! pushd "${SYSROOT}/usr/lib" ; then goto_exit 7 ; fi
    #    preAuthRoot && sudo rm libg2d*.so*libGL.so* libEGL*.so* libGAL*.so* libGLES*.so* libVIVANTE*.so* libVDK*.so*
    #    preAuthRoot && sudo rm pkgconfig/g2d*.pc pkgconfig/gl.pc pkgconfig/egl.pc pkgconfig/gles*.pc pkgconfig/gbm*.pc pkgconfig/vg*.pc
    #    pushd "arm-linux-gnueabihf"
    #        preAuthRoot && sudo rm libg2d*.so* libGL.so* libEGL*.so* libGAL*.so* libGLES*.so* libVIVANTE*.so* libVDK*.so*
    #        preAuthRoot && sudo rm pkgconfig/g2d*.pc pkgconfig/gl.pc pkgconfig/egl.pc pkgconfig/gles*.pc pkgconfig/gbm*.pc pkgconfig/vg*.pc
    #    popd
    #popd

    #if ! pushd "${SYSROOT}/usr/include" ; then goto_exit 8 ; fi
    #    preAuthRoot && sudo rm -rf g2d* CL EGL* GLES* HAL* KHR* VG* *viv*
    #popd

    if ! ( preAuthRoot && sudo cp -R --remove-destination "${CACHE}/${IMX_GPU_G2D}/g2d/usr/lib"/* "${SYSROOT}/usr/lib/arm-linux-gnueabihf/" ) ; then goto_exit 9 ; fi
    if ! ( preAuthRoot && sudo cp -R --remove-destination "${CACHE}/${IMX_GPU_G2D}/g2d/usr/include"/* "${SYSROOT}/usr/include/" ) ; then goto_exit 10 ; fi

    if ! ( preAuthRoot && sudo cp -R --remove-destination "${IMX_GPU_VIV}/gpu-core/usr/lib"/* "${SYSROOT}/usr/lib/arm-linux-gnueabihf/" ) ; then goto_exit 11 ; fi
    if ! ( preAuthRoot && sudo cp -R --remove-destination "${IMX_GPU_VIV}/gpu-core/usr/include"/* "${SYSROOT}/usr/include/" ) ; then goto_exit 12 ; fi
    if ! ( preAuthRoot && sudo cp -R --remove-destination "${IMX_GPU_VIV}/gpu-core/etc"/* "${SYSROOT}/etc/" ) ; then goto_exit 13 ; fi

    if ! pushd "${SYSROOT}/usr/lib" ; then goto_exit 14 ; fi
        preAuthRoot && sudo rm  -rf "dri"
        preAuthRoot && sudo ln -s "arm-linux-gnueabihf/dri" "dri"
    popd

    fix_chmod

popd

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

show_message "IMX GPU WAS SUCCESSFULLY INSTALLED!"
