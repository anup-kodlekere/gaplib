#!/bin/bash

usage() {
    echo "setup-build-env [flags]"
    echo ""
    echo "Where flags:"
    echo "-a <action runner git repo>  Where to find the action runner git repo"
    echo "                             defaults to ${ACTION_RUNNER}"
    echo "-o <exported image>          Path to exported image"
    echo "                             defaults to ${EXPORT}"
    echo "-s <SDK level>               .NET SDK level"
    echo "                             - Defaults to value in build script for ppc64le"
    echo "                             - Ignored for s390x which uses an RPM"
    echo "-t <1|0>                     - Include build tools/compilers in image. Defaults to 0."
    echo "-h                           Display this usage information"
    exit
}

ensure_lxd() {
  if ! command -v lxc version &> /dev/null
  then
    echo "LXD could not be found. Please ensure LXD exists."
    exit 1
  fi
}

build_image_in_container() {
  
  local IMAGE_ALIAS="${IMAGE_ALIAS:-${OS_NAME}-${OS_VERSION}-${ARCH}}"

  local BUILD_PREREQS_PATH="${SRCDIR}/build-files"
  if [ ! -d "${BUILD_PREREQS_PATH}" ]; then
      echo "Check the BUILD_PREREQS_PATH specification" >&2
      return 3
  fi
  local PATCH_FILE="${PATCH_FILE:-runner-${ARCH}.patch}"

  local BUILD_CONTAINER
  BUILD_CONTAINER="gha-builder-$(date +%s)"

  echo "Launching build container ${LXD_CONTAINER}"
  lxc launch "${LXD_CONTAINER}" "${BUILD_CONTAINER}" 
  lxc ls
  
  # give container some time to wake up and remap the filesystem
  for ((i = 0; i < 30; i++))
  do
      CHECK=`lxc exec ${BUILD_CONTAINER} -- stat ${BUILD_HOME} 2>/dev/null`
      if [ -n "${CHECK}" ]; then
          break
      fi
      sleep 2s
  done

  if [ -z "${CHECK}" ]; then
      echo "Unable to start the build container" >&2
      lxc delete -f ${BUILD_CONTAINER}
      return 2
  fi

  echo "Copy the build-image script into gha-builder"
  lxc file push --mode 0755 "${BUILD_PREREQS_PATH}/build-image.sh" "${BUILD_CONTAINER}${BUILD_HOME}/build-image.sh"
  
  echo "Copy the patch file into gha-builder"
  lxc file push ${BUILD_PREREQS_PATH}/${PATCH_FILE} "${BUILD_CONTAINER}${BUILD_HOME}/"

  echo "Copy the register-runner.sh script into gha-builder"
  lxc file push --mode 0755 ${BUILD_PREREQS_PATH}/register-runner.sh "${BUILD_CONTAINER}/opt/register-runner.sh"
  
  echo "Copy the /etc/rc.local - required in case podman is used"
  lxc file push --mode 0755 ${BUILD_PREREQS_PATH}/rc.local "${BUILD_CONTAINER}/etc/rc.local"
  
  echo "Copy the LXD preseed configuration"
  lxc file push --mode 0755 ${BUILD_PREREQS_PATH}/lxd-preseed.yaml "${BUILD_CONTAINER}/tmp/lxd-preseed.yaml"
  
  echo "Copy the gha-service unit file into gha-builder"
  lxc file push ${BUILD_PREREQS_PATH}/gha-runner.service "${BUILD_CONTAINER}/etc/systemd/system/gha-runner.service"

  echo "Copy the install-python script into gha-builder"
  lxc file push --mode 0755 "${BUILD_PREREQS_PATH}/install-python.sh" "${BUILD_CONTAINER}${BUILD_HOME}/install-python.sh"

  echo "Copy the install-ruby script into gha-builder"
  lxc file push --mode 0755 "${BUILD_PREREQS_PATH}/install-ruby.sh" "${BUILD_CONTAINER}${BUILD_HOME}/install-ruby.sh"

  echo "Running build-image.sh"
  lxc exec "${BUILD_CONTAINER}" --user 1000 --group 1000 -- ${BUILD_HOME}/build-image.sh -a ${ACTION_RUNNER} -s ${SDK} -t ${BTOOLS}
  RC=$?

  if [ ${RC} -eq 0 ]; then
      # Until we are at lxc >= 5.19 we can't use the --reuse option on the publish command
      echo "Deleting old image"
      lxc image delete ${IMAGE_ALIAS} 2>/dev/null

      echo "Runner build complete. Creating image snapshot."
      lxc publish "${BUILD_CONTAINER}" -f --alias "${IMAGE_ALIAS}" description="GitHub Actions ${OS_NAME} ${OS_VERSION} Runner for ${ARCH}"
  
      echo "Export the image to ${EXPORT} for use elsewhere"
      lxc image export "${IMAGE_ALIAS}" ${EXPORT}
  else
      echo "Build process failed with RC: $? - review log to determine cause of failure" >&2
  fi

  lxc delete -f "${BUILD_CONTAINER}"

  return ${RC}
}

run() {
  ensure_lxd
  build_image_in_container "$@"
  return $?
}

prolog() {
  export PATH=/snap/bin:${PATH}
  export SOURCE=$(readlink -f ${BASH_SOURCE[0]})
  export SRCDIR=$(dirname ${SOURCE})
  
  export ARCH=`uname -m`
  export ACTION_RUNNER="https://github.com/actions/runner"
  export EXPORT="distro/lxc-runner"
  export SDK=""
  export BTOOLS="0"

  export OS_NAME="${OS_NAME:-ubuntu}"
  export OS_VERSION="${OS_VERSION:-22.04}"
  export LXD_CONTAINER="${OS_NAME}:${OS_VERSION}"
  export BUILD_HOME="/home/ubuntu"

  mkdir -p distro

  X=`groups | grep -q lxd`
  if [ $? -eq 1 ]; then
      echo "Setting permissions"
      sudo chmod 0666 /var/snap/lxd/common/lxd/unix.socket
  fi
}

prolog
while getopts "a:o:ht:s:" opt
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
        t)
            BTOOLS="${OPTARG}"
            ;;
        s)
            SDK="${OPTARG}"
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
