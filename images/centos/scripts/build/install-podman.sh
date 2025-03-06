#!/bin/bash -e
################################################################################
##  File:  install-snap.sh
##  Desc:  Install snapd
################################################################################
source $HELPER_SCRIPTS/install.sh

dnf -y install podman