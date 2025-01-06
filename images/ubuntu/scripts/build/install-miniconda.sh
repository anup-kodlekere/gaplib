#!/bin/bash -e
################################################################################
##  File:  install-miniconda.sh
##  Desc:  Install miniconda
################################################################################
# Source the helpers for use with the script
source $HELPER_SCRIPTS/etc-environment.sh

if [[ "$ARCH" == "ppc64le" ]] ; then 
    # Install Miniconda
    curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-ppc64le.sh -o miniconda.sh \
        && chmod +x miniconda.sh \
        && ./miniconda.sh -b -p /usr/share/miniconda \
        && rm miniconda.sh
elif [[ "$ARCH" == "s390x" ]]; then
    # Install Miniconda
    curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-s390x.sh -o miniconda.sh \
        && chmod +x miniconda.sh \
        && ./miniconda.sh -b -p /usr/share/miniconda \
        && rm miniconda.sh
else
    # Install Miniconda
    curl -fsSL https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -o miniconda.sh \
        && chmod +x miniconda.sh \
        && ./miniconda.sh -b -p /usr/share/miniconda \
        && rm miniconda.sh
fi

CONDA=/usr/share/miniconda
set_etc_environment_variable "CONDA" "${CONDA}"

ln -s $CONDA/bin/conda /usr/bin/conda