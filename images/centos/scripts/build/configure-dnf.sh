#!/bin/bash -e
################################################################################
##  File:  configure-dnf.sh
##  Desc:  Configure dnf/yum, install jq package, and improve package management behavior.
################################################################################
# Source the helpers for use with the script
source $HELPER_SCRIPTS/install.sh
# Enable retries for DNF (maximum retries set to 10)
echo "retries=10" >> /etc/dnf/dnf.conf

# Automatically assume 'yes' for prompts in DNF
echo "assumeyes=True" >> /etc/dnf/dnf.conf

# Configure DNF to always consider phased updates
echo "phased_updates=1" >> /etc/dnf/dnf.conf

# Fix potential bad proxy or HTTP headers settings
cat <<EOF >> /etc/dnf/dnf.conf
http_caching=none
EOF

# Remove unattended-upgrade equivalents if present (e.g., dnf-automatic)
dnf remove -y dnf-automatic

# Display DNF repository configurations
echo 'DNF/YUM repositories:'
dnf repolist

# Update repositories and install jq
install_dnfpkgs jq

# Optional: Configure parallel downloads to speed up package installation
echo "max_parallel_downloads=10" >> /etc/dnf/dnf.conf