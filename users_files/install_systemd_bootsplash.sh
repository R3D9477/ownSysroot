#!/bin/bash

BRANCH="master"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if ! pushd "${CACHE}" ; then exit 1 ; fi

    if [ ! -d "ppmtofbimg-${BRANCH}" ] ; then
        if [ -f "ppmtofbimg-${BRANCH}.tar" ]; then
            tar -xf "ppmtofbimg-${BRANCH}.tar"
        else
            if git clone -b "${BRANCH}" --single-branch "https://github.com/rst-/raspberry-compote.git" "ppmtofbimg-${BRANCH}" ; then
                tar -cf "ppmtofbimg-${BRANCH}.tar" "ppmtofbimg-${BRANCH}"
            else
                exit 2
            fi
        fi
    fi

    #--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if ! pushd "ppmtofbimg-${BRANCH}/img" ; then exit 3 ; fi

        if ! ( "$CC" -O2 -o ppmtofbimg ppmtofbimg.c ) ; then exit 4 ; fi

        if ! ( preAuthRoot && sudo cp "ppmtofbimg" "${SYSROOT}/opt/" ) ; then exit 5 ; fi

        preAuthRoot && sudo cp "test24.ppm" "${SYSROOT}/opt/"

    popd

    #-------------------------------------------------------------------------------------------------------------------

    preAuthRoot && echo "[Unit]
Description=boot splash screen

[Service]
ExecStart=/opt/ppmtofbimg /opt/test24.ppm

[Install]
WantedBy=basic.target" | sudo tee "${SYSROOT}/etc/systemd/system/boot-image.service"

    preAuthRoot && sudo chroot "${SYSROOT}" systemctl enable boot-image.service

popd
