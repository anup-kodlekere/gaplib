#!/bin/bash -e
################################################################################
##  File:  install-azcopy.sh
##  Desc:  Install AzCopy
################################################################################

if [[ "$ARCH" == "ppc64le" ]]; then 
    # Placeholder for ppc64le-specific logic
    echo "No actions defined for ppc64le architecture."
elif [[ "$ARCH" == "s390x" ]]; then
    # Placeholder for s390x-specific logic
    echo "No actions defined for s390x architecture."
else
    # Source the helpers for use with the script
    source $HELPER_SCRIPTS/install.sh

    # Install AzCopy10
    archive_path=$(download_with_retry "https://aka.ms/downloadazcopy-v10-linux")
    tar xzf "$archive_path" --strip-components=1 -C /tmp
    install /tmp/azcopy /usr/local/bin/azcopy

    # Create azcopy 10 alias for backward compatibility
    ln -sf /usr/local/bin/azcopy /usr/local/bin/azcopy10
fi

