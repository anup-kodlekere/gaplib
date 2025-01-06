#!/bin/bash -e
################################################################################
##  File:  install-oras-cli.sh
##  Desc:  Install ORAS CLI
##  Supply chain security: ORAS CLI - checksum validation
################################################################################
# Source the helpers for use with the script
source $HELPER_SCRIPTS/install.sh

if [[ "$ARCH" == "ppc64le" ]] ; then 
    # Determine latest ORAS CLI version
    download_url=$(resolve_github_release_asset_url "oras-project/oras" "endswith(\"linux_ppc64le.tar.gz\")" "latest")

    # Download ORAS CLI
    archive_path=$(download_with_retry "$download_url")

    # Supply chain security - ORAS CLI
    hash_url=$(resolve_github_release_asset_url "oras-project/oras" "endswith(\"checksums.txt\")" "latest")
    external_hash=$(get_checksum_from_url "${hash_url}" "linux_ppc64le.tar.gz" "SHA256")
    use_checksum_comparison "$archive_path" "${external_hash}"

    # Unzip ORAS CLI
    tar xzf "$archive_path" -C /usr/local/bin oras
elif [[ "$ARCH" == "s390x" ]]; then
    # Placeholder for s390x-specific logic
    echo "No actions defined for s390x architecture."
else
    # Determine latest ORAS CLI version
    download_url=$(resolve_github_release_asset_url "oras-project/oras" "endswith(\"linux_amd64.tar.gz\")" "latest")

    # Download ORAS CLI
    archive_path=$(download_with_retry "$download_url")

    # Supply chain security - ORAS CLI
    hash_url=$(resolve_github_release_asset_url "oras-project/oras" "endswith(\"checksums.txt\")" "latest")
    external_hash=$(get_checksum_from_url "${hash_url}" "linux_amd64.tar.gz" "SHA256")
    use_checksum_comparison "$archive_path" "${external_hash}"

    # Unzip ORAS CLI
    tar xzf "$archive_path" -C /usr/local/bin oras
fi

