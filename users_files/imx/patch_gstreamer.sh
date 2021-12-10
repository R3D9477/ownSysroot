#!/bin/bash
show_current_task

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# INSTALL PATCHES -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

patch -N -t "${CACHE}/${gst_GITREPO}-${gst_BRANCH}/subprojects/gst-plugins-bad/gst-libs/gst/basecamerabinsrc/gstcamerabinpreview.c" -i "${USRDIR}/imx/GstPreview.patch"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

exit 0
