#!/bin/bash -e
################################################################################
##  File:  install-gfortran.sh
##  Desc:  Install GNU Fortran
################################################################################
# Source the helpers for use with the script
source $HELPER_SCRIPTS/install.sh

versions=$(get_toolset_value '.gfortran.versions[]')

for version in ${versions[*]}; do
    echo "Installing $version..."
    install_dpkgs $version 
done

echo "Install versionless gfortran (latest)"
install_dpkgs gfortran 
