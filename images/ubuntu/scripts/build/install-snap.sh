#!/bin/bash -e
################################################################################
##  File:  install-snap.sh
##  Desc:  Install snapd
################################################################################
source $HELPER_SCRIPTS/install.sh

# Install snapd if not already installed
echo "Installing snapd..."
if ! dpkg -l | grep -q snapd; then
    update_dpkgs
    install_dpkgs snapd
else
    echo "snapd is already installed."
fi

# Enable and start snapd socket
echo "Enabling and starting snapd.socket..."
sudo systemctl enable --now snapd.socket

# Create symbolic link for snap directory if not already exists
if [ ! -L /snap ]; then
    echo "Creating symbolic link for /snap..."
    sudo ln -s /var/lib/snapd/snap /snap
else
    echo "Symbolic link for /snap already exists."
fi

# Ensure /snap/bin is in the PATH
echo "Checking if /snap/bin is in the PATH..."
if [[ "$PATH" != *"/snap/bin"* ]]; then
    echo "/snap/bin is not in the PATH. Adding it now..."
    export PATH=/snap/bin:$PATH
    echo "export PATH=/snap/bin:$PATH" >> ~/.bashrc  # Persist for future sessions
    echo "/snap/bin has been added to the PATH."
else
    echo "/snap/bin is already in the PATH."
fi

echo "Checking the status of snapd.seeded.service..."
ensure_service_is_active snapd.seeded.service
ensure_service_is_active snapd.service

echo "Snapd setup and initialization completed successfully."