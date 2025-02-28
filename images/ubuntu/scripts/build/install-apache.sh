#!/bin/bash -e
################################################################################
##  File:  install-apache.sh
##  Desc:  Install Apache HTTP Server
################################################################################
# Source the helpers for use with the script
source $HELPER_SCRIPTS/install.sh
# Install Apache
install_dpkgs apache2

# Disable apache2.service
systemctl is-active --quiet apache2.service && systemctl stop apache2.service
systemctl disable apache2.service
