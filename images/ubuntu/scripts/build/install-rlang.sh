#!/bin/bash -e
################################################################################
##  File:  install-rlang.sh
##  Desc:  Install R
################################################################################
# Source the helpers for use with the script
source $HELPER_SCRIPTS/install.sh

if [[ "$ARCH" == "ppc64le" ]]; then 
    # Placeholder for ppc64le-specific logic
    echo "No actions defined for ppc64le architecture."
elif [[ "$ARCH" == "s390x" ]]; then
    # Placeholder for s390x-specific logic
    echo "No actions defined for s390x architecture."
else
    # install R
    os_label=$(lsb_release -cs)

    wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | gpg --dearmor > /usr/share/keyrings/rlang.gpg
    echo "deb [signed-by=/usr/share/keyrings/rlang.gpg] https://cloud.r-project.org/bin/linux/ubuntu $os_label-cran40/" > /etc/apt/sources.list.d/rlang.list

    update_dpkgs
    install_dpkgs r-base

    rm /etc/apt/sources.list.d/rlang.list
    rm /usr/share/keyrings/rlang.gpg
fi
