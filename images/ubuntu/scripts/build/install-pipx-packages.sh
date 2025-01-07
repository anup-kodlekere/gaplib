#!/bin/bash -e
################################################################################
##  File:  install-pipx-packages.sh
##  Desc:  Install tools via pipx
################################################################################
# Source the helpers for use with the script
source $HELPER_SCRIPTS/install.sh

export PATH="$PATH:/opt/pipx_bin"

pipx_packages=$(get_toolset_value ".pipx[] .package")

for package in $pipx_packages; do
    echo "Install $package into default python"

    # https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html
    # Install ansible into an existing ansible-core Virtual Environment
    if [[ $package == "ansible-core" && "$ARCH" != "ppc64le" && "$ARCH" != "s390x" ]]; then
        pipx install $package
        pipx inject $package ansible
    fi
done
