#!/bin/bash -e
################################################################################
##  File:  configure-dnfpkg.sh
##  Desc:  Configure dnf and package management settings
################################################################################

# Source the helpers for use with the script
source $HELPER_SCRIPTS/etc-environment.sh

# Configure dnf to automatically answer 'yes' for package installation
# This replaces the non-interactive mode typically set in DEBIAN_FRONTEND
echo "assumeyes=True" >> /etc/dnf/dnf.conf

# Prevent dnf from prompting for confirmation on replacing configuration files
# Equivalent to dpkg's --force-confdef --force-confold
echo "override_install_langs=en_US.UTF-8" >> /etc/dnf/dnf.conf

# Hide information about packages that are no longer required
# dnf has an autoremove feature, but it can be configured to prevent auto removal prompts
echo "clean_requirements_on_remove=True" >> /etc/dnf/dnf.conf

# Configure dnf to automatically clean up unused packages and dependencies
echo "autoclean_metadata=True" >> /etc/dnf/dnf.conf
