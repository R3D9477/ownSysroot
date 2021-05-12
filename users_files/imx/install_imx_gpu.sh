#!/bin/bash

IMX_GPU="imx-gpu-viv-5.0.11.p8.3-hfp"

IMX_EGL="fb"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# GET PACKAGES --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

IMX_BIN_URL="http://www.freescale.com/lgfiles/NMG/MAD/YOCTO"

if ! ( get_bin_pkg "${IMX_BIN_URL}" "${IMX_GPU}" ) ; then exit 1 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# INSTALL PACKAGES - --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

if ! pushd "$CACHE" ; then exit 1 ; fi

    if ! pushd "${IMX_GPU}/gpu-core/usr" ; then exit 1 ; fi

        # IMX GPU

        if ! pushd "include" ; then exit 1 ; fi
            rm libEGL.so* libGAL.so* libGLESv2.so* libVIVANTE.so* libOpenVG.so*
            ln -s libEGL-${IMX_EGL}.so libEGL.so
            ln -s libEGL-${IMX_EGL}.so libEGL.so.1
            ln -s libEGL-${IMX_EGL}.so libEGL.so.1.0
            ln -s libEGL-${IMX_EGL}.so libEGL.so.1.0.0
            ln -s libGAL-${IMX_EGL}.so libGAL.so
            ln -s libGLESv2-${IMX_EGL}.so libGLESv2.so
            ln -s libGLESv2-${IMX_EGL}.so libGLESv2.so.2
            ln -s libGLESv2-${IMX_EGL}.so libGLESv2.so.2.0.0
            ln -s libVIVANTE-${IMX_EGL}.so libVIVANTE.so
            ln -s libOpenVG.2d.so libOpenVG.so
        popd

        if ! pushd "include" ; then exit 1 ; fi
            sed -i 's|libdir=/usr/lib|libdir=/usr/lib/arm-linux-gnueabihf|g' *.pc
        popd
    popd

    if ! pushd "${SYSROOT}/usr/lib" ; then exit 1 ; fi
        preAuthRoot && sudo rm libg2d*.so*libGL.so* libEGL*.so* libGAL*.so* libGLES*.so* libVIVANTE*.so*
        preAuthRoot && sudo rm pkgconfig/g2d*.pc pkgconfig/gl.pc pkgconfig/egl.pc pkgconfig/gles*.pc
        pushd "arm-linux-gnueabihf"
            preAuthRoot && sudo rm libg2d*.so* libGL.so* libEGL*.so* libGAL*.so* libGLES*.so* libVIVANTE*.so*
            preAuthRoot && sudo rm pkgconfig/g2d*.pc pkgconfig/gl.pc pkgconfig/egl.pc pkgconfig/gles*.pc
        popd
    popd

    if ! pushd "${SYSROOT}/usr/include" ; then exit 1 ; fi
        preAuthRoot && sudo rm -rf g2d* CL EGL* GLES* HAL* KHR* VG* *viv*
    popd

    if ! ( preAuthRoot && sudo cp -R --remove-destination "${IMX_GPU}/g2d/usr/lib"/* "${SYSROOT}/usr/lib/arm-linux-gnueabihf/" ) ; then exit 2 ; fi
    if ! ( preAuthRoot && sudo cp -R --remove-destination "${IMX_GPU}/g2d/usr/include"/* "${SYSROOT}/usr/include/" ) ; then exit 3 ; fi

    if ! ( preAuthRoot && sudo cp -R --remove-destination "${IMX_GPU}/gpu-core/usr/lib"/* "${SYSROOT}/usr/lib/arm-linux-gnueabihf/" ) ; then exit 4 ; fi
    if ! ( preAuthRoot && sudo cp -R --remove-destination "${IMX_GPU}/gpu-core/usr/include"/* "${SYSROOT}/usr/include/" ) ; then exit 5 ; fi
    if ! ( preAuthRoot && sudo cp -R --remove-destination "${IMX_GPU}/gpu-core/etc"/* "${SYSROOT}/etc/" ) ; then exit 6 ; fi

    if ! pushd "${SYSROOT}/usr/lib" ; then exit 1 ; fi
        preAuthRoot && sudo rm  -rf "dri"
        preAuthRoot && sudo ln -s "arm-linux-gnueabihf/dri" "dri"
    popd

    fix_chmod

popd

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

echo ""
echo "    IMX GPU WAS SUCCESSFULLY INSTALLED!"
echo ""

exit 0
