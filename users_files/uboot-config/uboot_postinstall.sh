#!/bin/bash

if ! ( preAuthRoot && sudo cp "$USERDIR/uboot-config/uEnv.txt" "$BOOT/" )  ; then

    echo ""
    echo ">>> failed to install uBoot config"
    echo ""

    exit 1
fi


echo ""
echo ">>> uBoot config has been successfully installed"
echo ""

exit 0
