#!/bin/bash -e
################################################################################
##  File:  install-ms-repos.sh
##  Desc:  Install official Microsoft package repos for the distribution
################################################################################
os_label=$(lsb_release -rs)
source $HELPER_SCRIPTS/install.sh

# Install Microsoft repository
wget https://packages.microsoft.com/config/ubuntu/$os_label/packages-microsoft-prod.deb
dpkg -i packages-microsoft-prod.deb

# update
install_dpkgs apt-transport-https ca-certificates curl software-properties-common
update_dpkgs
apt-get dist-upgrade
