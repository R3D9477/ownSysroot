#!/bin/bash
show_current_task

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --

exportdefvar DEV_USBOTG_DEVICE          "/dev/sda3"
exportdefvar DEV_USBOTG_STATEF          "/sys/class/udc/ci_hdrc.0/state"
exportdefvar DEV_USBOTG_LUNF            "/sys/devices/soc*/soc/2100000.aips-bus/2184000.usb/ci_hdrc.0/gadget/lun0/file"
exportdefvar DEV_USBOTG_idVendor        "0"
exportdefvar DEV_USBOTG_iManufacturer   "0"
exportdefvar DEV_USBOTG_idProduct       "0"
exportdefvar DEV_USBOTG_iSerialNumber   "0"
exportdefvar DEV_USBOTG_bcdDevice       "0"
exportdefvar DEV_USBOTG_inquiry_string  "USB-OTG storage"

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --
# SET USB-OTG

preAuthRoot && echo "#!/bin/bash
if [ -f /var/lock/usbotg.lock ] ; then
    exit 1
fi
/bin/touch /var/lock/usbotg.lock
/bin/sync
/sbin/rmmod g_mass_storage -f &
/bin/sleep 2s
/sbin/modprobe g_mass_storage                       \\
    nofua=1                                         \\
    luns=1                                          \\
    ro=0                                            \\
    stall=0                                         \\
    removable=1                                     \\
    cdrom=0                                         \\
    idVendor=\"${DEV_USBOTG_idVendor}\"             \\
    iManufacturer=\"${DEV_USBOTG_iManufacturer}\"   \\
    idProduct=\"${DEV_USBOTG_idProduct}\"           \\
    iSerialNumber=\"${DEV_USBOTG_iSerialNumber}\"   \\
    bcdDevice=\"${DEV_USBOTG_bcdDevice}\"           \\
    inquiry_string=\"${DEV_USBOTG_inquiry_string}\" \\
    file=\"${DEV_USBOTG_DEVICE}\"
while [ \"\$(cat ${DEV_USBOTG_STATEF})\" == \"powered\" ] || [ \"\$(cat ${DEV_USBOTG_STATEF})\" == \"addressed\" ] ; do
    /bin/sleep 0.5s
done
USBOTG_CONN=1
while [ \${USBOTG_CONN} == 1 ] ; do
    USBOTG_CONN=0
    if [ \"\$(cat ${DEV_USBOTG_STATEF})\" == \"configured\" ] ; then
        if [ \"\$(cat ${DEV_USBOTG_LUNF})\" == \"${DEV_USBOTG_DEVICE}\" ] ; then
            USBOTG_CONN=1
            /bin/sleep 0.5s
        fi
    fi
done
/bin/rm /var/lock/usbotg.lock" | sudo tee "${SYSROOT}/opt/usbotg-start.sh"
preAuthRoot && sudo chmod +x "${SYSROOT}/opt/usbotg-start.sh"

preAuthRoot && echo "#!/bin/bash
/bin/rm /var/lock/usbotg.lock
/sbin/rmmod g_mass_storage -f
/sbin/rmmod usb_f_mass_storage -f
/sbin/rmmod libcomposite -f
/bin/umount /sys/kernel/config
/sbin/rmmod configfs -f" | sudo tee "${SYSROOT}/opt/usbotg-reset.sh"
preAuthRoot && sudo chmod +x "${SYSROOT}/opt/usbotg-reset.sh"

preAuthRoot && echo "[Unit]
Description=USB-OTG storage
[Service]
Type=simple
ExecStart=/opt/usbotg-start.sh
ExecStop=/opt/usbotg-reset.sh
[Install]
WantedBy=" | sudo tee "${SYSROOT}/etc/systemd/system/usbotg.service"
    
