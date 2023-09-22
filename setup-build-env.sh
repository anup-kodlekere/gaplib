#!/bin/bash

ensure_lxd() {
  if ! command -v lxc version &> /dev/null
  then
    echo "LXD could not be found. Please ensure LXD exists."
    exit
  fi
}

build_image_in_container() {
  
  export OS_NAME="${OS_NAME:-ubuntu}"
  export OS_VERSION="${OS_VERSION:-22.04}"
  export ARCH="${ARCH:-$(uname -m)}"
  export IMAGE_ALIAS="${IMAGE_ALIAS:-${OS_NAME}-${OS_VERSION}-${ARCH}}"

  export BUILD_PREREQS_PATH="${BUILD_PREREQS_PATH:-files}"
  export DOTNET_SDK="${DOTNET_SDK:-dotnet-sdk-7.0.100-linux-ppc64le.tar.gz}"
  export PATCH_FILE="${PATCH_FILE:-runner-ppc64le.patch}"

  export BUILD_CONTAINER
  BUILD_CONTAINER="gha-builder-$(date +%s)"
  lxc launch "${OS_NAME}:${OS_VERSION}" "${BUILD_CONTAINER}" 
  lxc ls
  
  # give container some time to wake up
  sleep 10
  
  echo "Copy the build-image script into gha-builder"
  lxc file push "${BUILD_PREREQS_PATH}/build-image.sh"  "${BUILD_CONTAINER}/home/ubuntu/"
  
  echo "Copy the dotnet-sdk into gha-builder"
  lxc file push "${BUILD_PREREQS_PATH}/${DOTNET_SDK}" "${BUILD_CONTAINER}/home/ubuntu/"
  
  echo "Copy the patch file into gha-builder"
  lxc file push "${BUILD_PREREQS_PATH}/${PATCH_FILE}" "${BUILD_CONTAINER}/home/ubuntu/"

  echo "Copy the register-runner.sh script into gha-builder"
  lxc file push "${BUILD_PREREQS_PATH}/register-runner.sh" "${BUILD_CONTAINER}/opt/register-runner.sh"
  
  echo "Copy the gha-service unit file into gha-builder"
  lxc file push "${BUILD_PREREQS_PATH}/gha-runner.service" "${BUILD_CONTAINER}/etc/systemd/system/gha-runner.service"

  echo "Setting executable permissions on register-runner.sh"
  lxc exec "${BUILD_CONTAINER}" -- chmod +x /opt/register-runner.sh
 
  echo "Setting executable permissions on build-image.sh"
  lxc exec "${BUILD_CONTAINER}" -- chmod +x /home/ubuntu/build-image.sh
  
  echo "Running build-image.sh"
  lxc exec "${BUILD_CONTAINER}" -- /home/ubuntu/build-image.sh
  
  #TODO: Have better error handling checks
  echo "Runner build complete. Creating image snapshot."

  lxc publish "${BUILD_CONTAINER}" -f --alias "$IMAGE_ALIAS" description="GitHub Actions Ubuntu 20.04 Runner for IBM Power."
  
  lxc delete -f "${BUILD_CONTAINER}"

}

run() {
  ensure_lxd
  echo "$1 in run"
  build_image_in_container "$1"
}

run "$@"
