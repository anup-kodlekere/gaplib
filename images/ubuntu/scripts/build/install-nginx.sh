#!/bin/bash -e
################################################################################
##  File:  install-nginx.sh
##  Desc:  Install Nginx
################################################################################
# Install Nginx
source $HELPER_SCRIPTS/os.sh
source $HELPER_SCRIPTS/install.sh
install_dpkgs nginx

# Disable nginx.service
systemctl is-active --quiet nginx.service && systemctl stop nginx.service
systemctl disable nginx.service
