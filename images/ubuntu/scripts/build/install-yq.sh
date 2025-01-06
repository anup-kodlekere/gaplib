#!/bin/bash -e
################################################################################
##  File:  install-yq.sh
##  Desc:  Install yq - a command-line YAML, JSON and XML processor
##  Supply chain security: yq - checksum validation
################################################################################
# Source the helpers for use with the script
source $HELPER_SCRIPTS/install.sh

if [ "$ARCH" = "ppc64le" ]; then
    # Download yq for ppc64le
    yq_url=$(resolve_github_release_asset_url "mikefarah/yq" "endswith(\"yq_linux_ppc64le\")" "latest")
    binary_path=$(download_with_retry "${yq_url}")

    # Supply chain security - yq for ppc64le
    # hash_url=$(resolve_github_release_asset_url "mikefarah/yq" "endswith(\"checksums\")" "latest")
    # external_hash=$(get_checksum_from_url "${hash_url}" "yq_linux_ppc64le" "SHA256" "true" " " "19")
    # use_checksum_comparison "$binary_path" "$external_hash"

elif [ "$ARCH" = "s390x" ]; then
    # Download yq for s390x
    yq_url=$(resolve_github_release_asset_url "mikefarah/yq" "endswith(\"yq_linux_s390x\")" "latest")
    binary_path=$(download_with_retry "${yq_url}")

    # Supply chain security - yq for s390x
    # hash_url=$(resolve_github_release_asset_url "mikefarah/yq" "endswith(\"checksums\")" "latest")
    # external_hash=$(get_checksum_from_url "${hash_url}" "yq_linux_s390x" "SHA256" "true" " " "19")
    # use_checksum_comparison "$binary_path" "$external_hash"

else
    # Download yq for amd64
    yq_url=$(resolve_github_release_asset_url "mikefarah/yq" "endswith(\"yq_linux_amd64\")" "latest")
    binary_path=$(download_with_retry "${yq_url}")

    # Supply chain security - yq for amd64
    hash_url=$(resolve_github_release_asset_url "mikefarah/yq" "endswith(\"checksums\")" "latest")
    external_hash=$(get_checksum_from_url "${hash_url}" "yq_linux_amd64" "SHA256" "true" " " "19")
    use_checksum_comparison "$binary_path" "$external_hash"

fi

# Install yq
install "$binary_path" /usr/bin/yq