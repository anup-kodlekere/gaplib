#!/bin/bash

ensure_lxd() {
  if ! command -v lxc version &> /dev/null
  then
    echo "LXD could not be found. Please ensure LXD exists."
    exit
  fi
}

build_image_in_container() {
  
  local BUILD_PREREQS_PATH="/home/ubuntu/remote-build/files"
  local DOTNET_SDK="dotnet-sdk-7.0.100-linux-ppc64le.tar.gz"
  local PATCH_FILE="runner-ppc64le-final.patch"

  local BUILD_CONTAINER=gha-builder-$(date +%s)
  lxc launch ubuntu:20.04 "${BUILD_CONTAINER}"
  lxc ls
  
  # give container some time to wake up
  sleep 10
  
  echo "Copy the build-image script into gha-builder"
  lxc file push "${BUILD_PREREQS_PATH}/build-image.sh"  "${BUILD_CONTAINER}/home/ubuntu/"
  
  echo "Copy the dotnet-sdk into gha-builder"
  lxc file push "${BUILD_PREREQS_PATH}/${DOTNET_SDK}" "${BUILD_CONTAINER}/home/ubuntu/"
  
  echo "Copy the patch file into gha-builder"
  lxc file push "${BUILD_PREREQS_PATH}/${PATCH_FILE}" "${BUILD_CONTAINER}/home/ubuntu/"
  
  echo "Setting executable permissions on build-image.sh"
  lxc exec "${BUILD_CONTAINER}" -- chmod +x /home/ubuntu/build-image.sh
  
  echo "Running build-image.sh"
  lxc exec "${BUILD_CONTAINER}" -- /home/ubuntu/build-image.sh
  
  #TODO: Have better error handling checks
  echo "Runner build complete. Creating image snapshot."
  
  lxc snapshot "${BUILD_CONTAINER}" ubuntu-2004-power-runner
  lxc publish "${BUILD_CONTAINER}/ubuntu-2004-power-runner" --alias ubuntu-2004-power-runner description="GitHub Actions Ubuntu 20.04 Runner for IBM Power."
  
  lxc delete -f "${BUILD_CONTAINER}"

}

run() {
  ensure_lxd
  build_image_in_container
}

run "$@"
