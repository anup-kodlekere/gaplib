#!/bin/bash -e
################################################################################
##  File:  install-terraform.sh
##  Desc:  Install terraform
################################################################################
source $HELPER_SCRIPTS/install.sh

if [[ "$ARCH" == "ppc64le" ]]; then 
    wget -O /usr/local/bin/terraform https://ftp2.osuosl.org/pub/ppc64el/terraform/terraform-1.4.6
    chmod +x /usr/local/bin/terraform ;
elif [[ "$ARCH" == "s390x" ]]; then
    # Placeholder for s390x-specific logic
    echo "No actions defined for s390x architecture."
else
    # Install Terraform
    download_url=$(curl -fsSL https://api.releases.hashicorp.com/v1/releases/terraform/latest | jq -r '.builds[] | select((.arch=="amd64") and (.os=="linux")).url')
    archive_path=$(download_with_retry "${download_url}")
    unzip -qq "$archive_path" -d /usr/local/bin
fi

