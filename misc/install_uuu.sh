#!/bin/bash

sudo apt install wget unzip git libusb-1.0-0-dev libzip-dev libbz2-dev pkg-config cmake libssl-dev g++ -y

git clone "https://github.com/NXPmicro/mfgtools.git"

pushd "mfgtools"

    wget -nc "https://www.voipac.com/downloads/imx/iMX6_OpenRex/Tools/mfgtools-Imx6Rex.zip"
    unzip "mfgtools-Imx6Rex.zip"
    rm -f "mfgtools-Imx6Rex.zip"
    
    cmake . && make
    
    echo '#!/bin/bash
cd $(realpath "`dirname "$0"`")/uuu && sudo ./uuu "../mfgtools-Imx6Rex/Profiles/Linux/OS Firmware/firmware/u-boot-imx6-tinyrexbasic.imx"' > "Production-TinyRex-basic.sh"
    chmod +x "Production-TinyRex-basic.sh"

    echo '#!/bin/bash
cd $(realpath "`dirname "$0"`")/uuu && sudo ./uuu "../mfgtools-Imx6Rex/Profiles/Linux/OS Firmware/firmware/u-boot-imx6-openrexbasic.imx"' > "Production-OpenRex-basic.sh"
    chmod +x "Production-OpenRex-basic.sh"

popd 
