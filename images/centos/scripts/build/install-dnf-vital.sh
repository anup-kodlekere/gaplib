#!/bin/bash -e
################################################################################
##  File:  install-dnf-vital.sh
##  Desc:  Install vital command-line utilities
################################################################################
# Source the helpers for use with the script
source $HELPER_SCRIPTS/install.sh

vital_packages=$(get_toolset_value .dnf.vital_packages[])

# Install vital packages using dnf
install_dnfpkgs --setopt=install_weak_deps=False $vital_packages
