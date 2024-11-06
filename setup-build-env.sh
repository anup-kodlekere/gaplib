#!/bin/bash

usage() {
    echo "setup-build-env [flags]"
    echo ""
    echo "Where flags:"
    echo "-a <action runner git repo>  Where to find the action runner git repo"
    echo "                             defaults to ${ACTION_RUNNER}"
    echo "-o <exported image>          Path to exported image"
    echo "                             defaults to ${EXPORT}"
    echo "-h                           Display this usage information"
    exit
}

msg() {
    echo `date +"%Y-%m-%dT%H:%M:%S%:z"` $*
}

ensure_lxd() {
  if ! command -v lxc version &> /dev/null
  then
    msg "LXD could not be found. Please ensure LXD exists."
    exit 1
  fi
}

build_image_in_container() {
  
  local IMAGE_ALIAS="${IMAGE_ALIAS:-${OS_NAME}-${OS_VERSION}-${ARCH}}"

  local BUILD_PREREQS_PATH="${SRCDIR}/build-files"
  if [ ! -d "${BUILD_PREREQS_PATH}" ]; then
      msg "Check the BUILD_PREREQS_PATH specification" >&2
      return 3
  fi
  local PATCH_FILE="${PATCH_FILE:-runner-sdk-8.patch}"

  local BUILD_CONTAINER
  BUILD_CONTAINER="gha-builder-$(date +%s)"

  msg "Launching build container ${LXD_CONTAINER}"
  lxc launch "${LXD_CONTAINER}" "${BUILD_CONTAINER}" 
  lxc ls
  
  # give container some time to wake up and remap the filesystem
  for ((i = 0; i < 90; i++))
  do
      CHECK=`lxc exec ${BUILD_CONTAINER} -- stat ${BUILD_HOME} 2>/dev/null`
      if [ -n "${CHECK}" ]; then
          break
      fi
      sleep 2s
  done

  if [ -z "${CHECK}" ]; then
      msg "Unable to start the build container" >&2
      lxc delete -f ${BUILD_CONTAINER}
      return 2
  fi

  msg "Copy the build-image script into gha-builder"
  lxc file push --mode 0755 "${BUILD_PREREQS_PATH}/build-image.sh" "${BUILD_CONTAINER}${BUILD_HOME}/build-image.sh"
  
  msg "Copy the build-image script into gha-builder"
  lxc file push --mode 0755 "${BUILD_PREREQS_PATH}/install-packages.sh" "${BUILD_CONTAINER}${BUILD_HOME}/install-packages.sh"

  msg "Copy the supported packages list into the gha-builder"
  lxc file push --mode 0755 "${BUILD_PREREQS_PATH}/supported_packages.txt" "${BUILD_CONTAINER}${BUILD_HOME}/supported_packages.txt"

  msg "Copy the patch file into gha-builder"
  lxc file push ${BUILD_PREREQS_PATH}/${PATCH_FILE} "${BUILD_CONTAINER}${BUILD_HOME}/"

  msg "Copy the register-runner.sh script into gha-builder"
  lxc file push --mode 0755 ${BUILD_PREREQS_PATH}/register-runner.sh "${BUILD_CONTAINER}/opt/register-runner.sh"
  
  msg "Copy the /etc/rc.local - required in case podman is used"
  lxc file push --mode 0755 ${BUILD_PREREQS_PATH}/rc.local "${BUILD_CONTAINER}/etc/rc.local"
  
  msg "Copy the LXD preseed configuration"
  lxc file push --mode 0755 ${BUILD_PREREQS_PATH}/lxd-preseed.yaml "${BUILD_CONTAINER}/tmp/lxd-preseed.yaml"
  
  msg "Copy the gha-service unit file into gha-builder"
  lxc file push ${BUILD_PREREQS_PATH}/gha-runner.service "${BUILD_CONTAINER}/etc/systemd/system/gha-runner.service"

  msg "Copy the apt and dpkg overrides into gha-builder - these prevent doc files from being installed"
  lxc file push --mode 0644 "${BUILD_PREREQS_PATH}/99synaptics" "${BUILD_CONTAINER}/etc/apt/apt.conf.d/99synaptics"
  lxc file push --mode 0644 "${BUILD_PREREQS_PATH}/01-nodoc" "${BUILD_CONTAINER}/etc/dpkg/dpkg.cfg.d/01-nodoc"

  msg "Setting user ubuntu with sudo privileges"
  lxc exec "${BUILD_CONTAINER}" --user 0 --group 0 -- sh -c "echo 'ubuntu ALL=(ALL) NOPASSWD:ALL' | sudo EDITOR='tee -a' visudo"
  
  msg "Running build-image.sh"
  lxc exec "${BUILD_CONTAINER}" --user 1000 --group 1000 -- ${BUILD_HOME}/build-image.sh -a ${ACTION_RUNNER}
  RC=$?

  if [ ${RC} -eq 0 ]; then
      msg "Running install-packages.sh"
      lxc exec "${BUILD_CONTAINER}" --user 1000 --group 1000 -- ${BUILD_HOME}/install-packages.sh ${BUILD_HOME}/supported_packages.txt

      # Until we are at lxc >= 5.19 we can't use the --reuse option on the publish command
      msg "Deleting old image"
      lxc image delete ${IMAGE_ALIAS} 2>/dev/null

      msg "Runner build complete. Creating image snapshot."
      lxc snapshot "${BUILD_CONTAINER}" "build-snapshot"
      lxc publish "${BUILD_CONTAINER}/build-snapshot" -f --alias "${IMAGE_ALIAS}" \
            --compression none \
            description="GitHub Actions ${OS_NAME} ${OS_VERSION} Runner for ${ARCH}"
  
      msg "Export the image to ${EXPORT} for use elsewhere"
      lxc image export "${IMAGE_ALIAS}" ${EXPORT}

      msg "Priming the filesystem by launching the newly built container"
      lxc launch "${IMAGE_ALIAS}" "primer"
      lxc rm -f primer
  else
      msg "Build process failed with RC: ${RC} - review log to determine cause of failure" >&2
  fi

  lxc delete -f "${BUILD_CONTAINER}"

  return ${RC}
}

run() {
  ensure_lxd
  build_image_in_container "$@"
  return $?
}

select_ubuntu_version() {
  case "$ARCH" in
    ppc64le)
      export OS_VERSION="22.04"
      ;;
    s390x)
      export OS_VERSION="24.10"
      ;;
    *)
      export OS_VERSION="24.10" # Default version for other architectures
      ;;
  esac
}
prolog() {
  export PATH=/snap/bin:${PATH}
  export SOURCE=$(readlink -f ${BASH_SOURCE[0]})
  export SRCDIR=$(dirname ${SOURCE})
  
  export ARCH=`uname -m`
  export ACTION_RUNNER="https://github.com/actions/runner"
  export EXPORT="distro/lxc-runner"
  export OS_NAME="${OS_NAME:-ubuntu}"
  export BUILD_HOME="/home/ubuntu"

  select_ubuntu_version "$@"

  export LXD_CONTAINER="${OS_NAME}:${OS_VERSION}"

  mkdir -p distro

  X=`groups | grep -q lxd`
  if [ $? -eq 1 ]; then
      msg "Setting permissions"
      sudo chmod 0666 /var/snap/lxd/common/lxd/unix.socket
  fi
}

prolog
while getopts "a:o:h:" opt
do
    case "${opt}" in
        a)
            ACTION_RUNNER=${OPTARG}
            ;;
        o)
            EXPORT=${OPTARG}
            ;;
        h)
            usage
            ;;
        *)
            usage
            ;;
    esac
done
shift $(( OPTIND - 1 ))
run "$@"
RC=$?
exit ${RC}
