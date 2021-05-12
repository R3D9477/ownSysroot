#!/bin/bash

# REMOVE ETH0

preAuthRoot && sudo rm "${SYSROOT}"/etc/network/interfaces.d/*eth*
