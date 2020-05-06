#!/bin/bash

BRANCH="v5.2.2.4"

if [ -z "$rtl8188eu_RECOMPILE" ]; then export rtl8188eu_RECOMPILE="a" ; fi

#--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

if ! pushd "$CACHE" ; then exit 1 ; fi

    if [ ! -d "rtl8188eu-$BRANCH" ] ; then
        if [ -f "rtl8188eu-$BRANCH.tar" ]; then
            tar -xf "rtl8188eu-$BRANCH.tar"
        else
            if git clone -b "$BRANCH" --single-branch "https://github.com/lwfinger/rtl8188eu.git" "rtl8188eu-$BRANCH" ; then
                tar -cf "rtl8188eu-$BRANCH.tar" "rtl8188eu-$BRANCH"
            else
                exit 2
            fi
        fi
    fi

    #--- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- --- ---

    if ! pushd "rtl8188eu-$BRANCH" ; then exit 3 ; fi

        KVER=$(cd "$SYSROOT/lib/" && ls "modules")
        KERNEL_DIR=$(realpath -s "$SYSROOT/lib/modules/$KVER/build")

        sed -i 's#KSRC :=#KSRC ?=#g' Makefile
        sed -i 's#KERNEL_SRC :=#KERNEL_SRC ?=#g' Makefile

        # MAKE

        if ( [ "$rtl8188eu_RECOMPILE" == "y" ] || ( [ "$rtl8188eu_RECOMPILE" == "a" ] && ! [ -f "8188ue.ko" ] ) ) ; then
            make clean
            if ! make ARCH=$ARCH CROSS_COMPILE="$TOOLCHAIN_PREFIX" KSRC="$KERNEL_DIR" KERNEL_SRC="$KERNEL_DIR" $NJ ; then exit 4 ; fi
        fi

        # INSTALL

        preAuthRoot && sudo cp "8188eu.ko" "$SYSROOT/opt/"
        preAuthRoot && sudo mkdir -p "$SYSROOT/lib/modules/$KVER/kernel/drivers/net/wireless/"
        if ! ( preAuthRoot && sudo chroot "$SYSROOT" install -p -m 644 "/opt/8188eu.ko" "/lib/modules/$KVER/kernel/drivers/net/wireless/" ) ; then exit 5 ; fi
        if ! ( preAuthRoot && sudo chroot "$SYSROOT" depmod -a "$KVER" ) ; then exit 6 ; fi
        preAuthRoot && sudo rm "$SYSROOT/opt/8188eu.ko"

        preAuthRoot && sudo mkdir -p "$SYSROOT/lib/firmware/rtlwifi"
        preAuthRoot && sudo cp "rtl8188eufw.bin" "$SYSROOT/lib/firmware/rtlwifi/"
        preAuthRoot && sudo chroot "$SYSROOT" chmod -R +x "/lib/firmware/rtlwifi"

        preAuthRoot && echo "blacklist r8188eu" | sudo tee "$SYSROOT/etc/modprobe.d/50-8188eu.conf"

    popd

popd
