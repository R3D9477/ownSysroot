#!/bin/bash

LO_DEV=`sudo losetup -f`

docker run -it \
    -v /home/eugene/DMT_MCP1:/mnt/mcp1 \
    -v /home/eugene/Projects/r3d9u11/imx6deb:/mnt/mcp1/imx6deb \
    -v /dev/$LD_DEV:/dev/$LD_DEV: \
    -v /dev/mapper:/dev/mapper \
    --privileged \
    mcp1dev-ubuntu
