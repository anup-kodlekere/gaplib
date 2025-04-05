#!/bin/bash

HELPERS_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/helpers"

source ${HELPERS_DIR}/setup_vars.sh
source ${HELPERS_DIR}/setup_img.sh
source ${HELPERS_DIR}/run_script.sh

# Function to ensure Podman is installed and available
ensure_podman() {
    if ! command -v podman &> /dev/null; then
        echo "Podman is not installed. Attempting to install Podman..."
        if run_script "${HOST_INSTALLER_SCRIPT_FOLDER}/install-podman.sh" "DOCKERHUB_PULL_IMAGES" "HELPER_SCRIPTS" "INSTALLER_SCRIPT_FOLDER" "ARCH"; then
            echo "Podman installed successfully."
        else
            echo "Failed to install Podman. Please check your system configuration." >&2
            exit 1
        fi
    else
        echo "Podman is already installed. Version: $(podman --version)"
    fi
}

# Function to build a Podman image
build_image() {
    local dockerfile="${HELPERS_DIR}/../../dockerfiles/Dockerfile.${IMAGE_OS}.${IMAGE_VERSION}"

    if [ ! -f "$dockerfile" ]; then
        echo "Error: Dockerfile for ${IMAGE_OS} version ${IMAGE_VERSION} not found." >&2
        return 1
    fi
    echo "Building Podman image for ${IMAGE_OS} version ${IMAGE_VERSION}..."
    podman build --no-cache -f "$dockerfile" \
        --build-arg RUNNERPATCH="../patches/${PATCH_FILE}" \
        --build-arg ARCH="${ARCH}" \
        --tag "runner:${IMAGE_OS}.${IMAGE_VERSION}" .

    if [ $? -eq 0 ]; then
        echo "Podman image built successfully: runner:${IMAGE_OS}.${IMAGE_VERSION}"
    else
        echo "Error: Failed to build Podman image." >&2
        return 1
    fi
}

# Main function to run the script
run() {
    # Export system architecture
    ARCH=$(uname -m)
    HOST_OS_NAME=$(awk -F= '/^NAME/{print $2}' /etc/os-release | tr -d '"' | tr '[:upper:]' '[:lower:]' | awk '{print $1}')
    HOST_OS_VERSION=$(cat /etc/os-release | grep -E 'VERSION_ID' | cut -d'=' -f2 | tr -d '"')
    HOST_INSTALLER_SCRIPT_FOLDER="${HELPERS_DIR}/../../images/${HOST_OS_NAME}/scripts/build"

    echo "Host OS: ${HOST_OS_NAME} ${HOST_OS_VERSION}, Architecture: ${ARCH}"
    echo "Target container OS: ${IMAGE_OS} ${IMAGE_VERSION}"

    # Ensure Podman is installed
    ensure_podman "$@"

    # Build the Podman image
    build_image "$@"
    return $?
}

# Execute the main function
run "$@"
RC=$?

# Exit with the return code of the main function
exit ${RC}
