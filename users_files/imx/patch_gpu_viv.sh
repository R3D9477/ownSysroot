#!/bin/bash
show_current_task

exportdefvar IMX_GPU_VIV_PATCH_FILE "${USERDIR}/imx/imx6gpu_${IMX_GPU_VIV}.patch"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
# INSTALL PATCHES -- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

show_message "PATCH: ${IMX_GPU_VIV_PATCH_FILE}"

if [ -f "${IMX_GPU_VIV_PATCH_FILE}" ] ; then
    show_message "ORIG:  ${CACHE}/${IMX_GPU_VIV}"
    patch -N -t -d "${CACHE}/${IMX_GPU_VIV}" -p0 -i "${IMX_GPU_VIV_PATCH_FILE}"
else
    show_message "PATCH WAS NOT FOUND! Ignored."
fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -
#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- -

exit 0
