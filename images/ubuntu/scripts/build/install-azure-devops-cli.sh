#!/bin/bash -e
################################################################################
##  File:  install-azure-devops-cli.sh
##  Desc:  Install Azure DevOps CLI (az devops)
################################################################################

if [[ "$ARCH" == "ppc64le" ]]; then 
    # Placeholder for ppc64le-specific logic
    echo "No actions defined for ppc64le architecture."
elif [[ "$ARCH" == "s390x" ]]; then
    # Placeholder for s390x-specific logic
    echo "No actions defined for s390x architecture."
else
    # Source the helpers for use with the script
    source $HELPER_SCRIPTS/etc-environment.sh

    # AZURE_EXTENSION_DIR shell variable defines where modules are installed
    # https://docs.microsoft.com/en-us/cli/azure/azure-cli-extensions-overview
    export AZURE_EXTENSION_DIR=/opt/az/azcliextensions
    set_etc_environment_variable "AZURE_EXTENSION_DIR" "${AZURE_EXTENSION_DIR}"

    # install azure devops Cli extension
    az extension add -n azure-devops
fi