#!/bin/bash -e
################################################################################
##  File:  install-dnf-common.sh
##  Desc:  Install basic command-line utilities and development packages
################################################################################
# Source the helpers for use with the script
source $HELPER_SCRIPTS/install.sh

common_packages=$(get_toolset_value .dnf.common_packages[])
cmd_packages=$(get_toolset_value .dnf.cmd_packages[])

for package in $common_packages $cmd_packages; do
    echo "Install $package"
    dnf install -y --setopt=install_weak_deps=False $package
done