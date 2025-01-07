#!/bin/bash -e
################################################################################
##  File:  install-lxd.sh
##  Desc:  Install lxd
################################################################################
source $HELPER_SCRIPTS/install.sh

# Install LXD using snap
echo "Installing LXD using snap..."
sudo snap install lxd

echo "Checking the status of snap.lxd.daemon..."
ensure_service_is_active snap.lxd.daemon

# Initialize LXD
echo "Initializing LXD..."
cat $INSTALLER_SCRIPT_FOLDER/lxd-preseed.yaml | sudo -i lxd init --preseed
echo "LXD is ready to use!"

