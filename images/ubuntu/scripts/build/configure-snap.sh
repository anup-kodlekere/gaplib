#!/bin/bash -e
################################################################################
##  File:  configure-snap.sh
##  Desc:  Configure snap
################################################################################
# Source the helpers for use with the script
source $HELPER_SCRIPTS/etc-environment.sh

# Update /etc/environment to include /snap/bin in PATH
# because /etc/profile.d is ignored by `--norc` shell launch option
if [[ ":$PATH:" == *"/snap/bin"* ]]; then
    echo "/snap/bin is already in the PATH"
else
    echo "/snap/bin is not in the PATH. Adding it now..."
    export PATH=/snap/bin:$PATH
    echo "export PATH=/snap/bin:$PATH" >> ~/.bashrc  # Persist for future sessions
    echo "/snap/bin has been added to the PATH"
fi
# Put snapd auto refresh on hold
# as it may generate too much traffic on Canonical's snap server
# when they are rolling a new major update out.
# Hold is calculated as today's date + 60 days

# snapd is started automatically, but during image generation
# a unix socket may die, restart snapd.service (and therefore snapd.socket)
# to make sure the socket is alive.

systemctl restart snapd.socket
systemctl restart snapd
snap set system refresh.hold="$(date --date='today+60 days' +%Y-%m-%dT%H:%M:%S%:z)"
