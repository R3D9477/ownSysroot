#!/bin/bash
show_current_task

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

exportdefvar ppmtofbimg_GITURL     "https://github.com/rst"
exportdefvar ppmtofbimg_GITREPO    "raspberry-compote"
exportdefvar ppmtofbimg_BRANCH     "master"
exportdefvar ppmtofbimg_REVISION   ""
exportdefvar ppmtofbimg_RECOMPILE  n

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# GET PACKAGES --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if ! ( get_git_pkg "${ppmtofbimg_GITURL}" "${ppmtofbimg_GITREPO}" "${ppmtofbimg_BRANCH}" "${ppmtofbimg_REVISION}" ) ; then goto_exit 1 ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# INSTALL PACKAGES - --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

if ! pushd "${CACHE}/${ppmtofbimg_GITREPO}-${ppmtofbimg_BRANCH}/ppmtofbimg" ; then goto_exit 2 ; fi

    if ! ( "$CC" -O2 -o ppmtofbimg ppmtofbimg.c ) ; then exit 3 ; fi

    if ! ( preAuthRoot && sudo cp "ppmtofbimg" "${SYSROOT}/opt/" ) ; then exit 4 ; fi

    preAuthRoot && sudo cp "test24.ppm" "${SYSROOT}/opt/"

    preAuthRoot && echo "[Unit]
Description=boot splash screen

[Service]
ExecStart=/opt/ppmtofbimg /opt/test24.ppm

[Install]
WantedBy=basic.target" | sudo tee "${SYSROOT}/etc/systemd/system/boot-image.service"

    preAuthRoot && sudo chroot "${SYSROOT}" systemctl enable boot-image.service

popd

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

show_message "ppmtofbimg WAS SUCCESSFULLY INSTALLED!"
