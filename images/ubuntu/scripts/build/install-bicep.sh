#!/bin/bash -e
################################################################################
##  File:  install-bicep.sh
##  Desc:  Install bicep cli
################################################################################
# Source the helpers for use with the script
source $HELPER_SCRIPTS/install.sh

if [[ "$ARCH" == "ppc64le" ]]; then 
    # Placeholder for ppc64le-specific logic
    echo "No actions defined for ppc64le architecture."
elif [[ "$ARCH" == "s390x" ]]; then
    # Placeholder for s390x-specific logic
    echo "No actions defined for s390x architecture."
else
    # Install Bicep CLI
    download_url=$(resolve_github_release_asset_url "Azure/bicep" "endswith(\"bicep-linux-x64\")" "latest")
    bicep_binary_path=$(download_with_retry "${download_url}")

    # Mark it as executable
    install "$bicep_binary_path" /usr/local/bin/bicep
fi

