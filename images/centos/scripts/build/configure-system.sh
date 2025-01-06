#!/bin/bash -e
################################################################################
##  File: configure-system.sh
##  Desc: Post deployment system configuration actions for CentOS
################################################################################

# Source helper scripts
source $HELPER_SCRIPTS/etc-environment.sh
source $HELPER_SCRIPTS/os.sh

# Move post-generation files to /opt
mv -f /imagegeneration/post-generation /opt

# Adjust permissions
echo "chmod -R 777 /opt"
chmod -R 777 /opt
echo "chmod -R 777 /usr/share"
chmod -R 777 /usr/share

chmod 755 $IMAGE_FOLDER

# Remove quotes around PATH in /etc/environment
ENVPATH=$(grep 'PATH=' /etc/environment | head -n 1 | sed -z 's/^PATH=*//')
ENVPATH=${ENVPATH#"\""}
ENVPATH=${ENVPATH%"\""}
replace_etc_environment_variable "PATH" "${ENVPATH}"
echo "Updated /etc/environment: $(cat /etc/environment)"

# Clean yarn and npm cache if installed
if command -v yarn > /dev/null; then
    yarn cache clean
fi

if command -v npm > /dev/null; then
    npm cache clean --force
fi
