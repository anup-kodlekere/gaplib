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
      exit 3
  fi
  local PATCH_FILE="${PATCH_FILE:-runner-${ARCH}.patch}"

  local BUILD_CONTAINER
  BUILD_CONTAINER="gha-builder-$(date +%s)"
  lxc launch "${LXD_CONTAINER}" "${BUILD_CONTAINER}" 
  lxc ls
  
  # give container some time to wake up
  sleep 5
  
  echo "Copy the build-image script into gha-builder"
  echo ${BUILD_PREREQS_PATH}
  echo ${BUILD_PREREQS_PATH}/build-image.sh-${ARCH}
  lxc file push --mode 0755 "${BUILD_PREREQS_PATH}/build-image.sh-${ARCH}" "${BUILD_CONTAINER}${BUILD_HOME}/build-image.sh"
  sleep 10s
  
  if [ -n "${DOTNET_SDK}" ]; then
      echo "Copy the dotnet-sdk into gha-builder"
      lxc file push ${BUILD_PREREQS_PATH}/${DOTNET_SDK} "${BUILD_CONTAINER}${BUILD_HOME}"
  fi
  
  echo "Copy the patch file into gha-builder"
  lxc file push ${BUILD_PREREQS_PATH}/${PATCH_FILE} "${BUILD_CONTAINER}${BUILD_HOME}/"

  echo "Copy the register-runner.sh script into gha-builder"
  lxc file push --mode 0755 ${BUILD_PREREQS_PATH}/register-runner.sh "${BUILD_CONTAINER}/opt/register-runner.sh"
  
  echo "Copy the gha-service unit file into gha-builder"
  lxc file push ${BUILD_PREREQS_PATH}/gha-runner.service "${BUILD_CONTAINER}/etc/systemd/system/gha-runner.service"

  echo "Running build-image.sh"
  lxc exec "${BUILD_CONTAINER}" -- ${BUILD_HOME}/build-image.sh -a ${ACTION_RUNNER} ${SDK}
  RC=$?

  if [ ${RC} -eq 0 ]; then
      echo "Runner build complete. Creating image snapshot."
      lxc publish --reuse "${BUILD_CONTAINER}" -f --alias "${IMAGE_ALIAS}" description="GitHub Actions ${OS_NAME} ${OS_VERSION} Runner for ${ARCH}"
  
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

PATH=/snap/bin:${PATH}
SOURCE=$(readlink -f ${BASH_SOURCE[0]})
SRCDIR=$(dirname ${SOURCE})

ARCH=`uname -m`
ACTION_RUNNER="https://github.com/actions/runner"
EXPORT="distro/lxc-runner"
SDK=""
while getopts "a:o:hs:" opt
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
        s)
            SDK="-s ${OPTARG}"
            ;;
        *)
            usage
            ;;
    esac
done
case "${ARCH}" in
    ppc64le)
        OS_NAME="${OS_NAME:-ubuntu}"
        OS_VERSION="${OS_VERSION:-22.04}"
        LXD_CONTAINER="${OS_NAME}:${OS_VERSION}"
        DOTNET_SDK="${DOTNET_SDK:-dotnet-sdk-7.0.100-linux-${ARCH}.tar.gz}"
        BUILD_HOME="/home/ubuntu"
        ;;
    s390x)
        OS_NAME="${OS_NAME:-almalinux}"
        OS_VERSION="${OS_VERSION:-9}"
        if [ ! -f "${SRCDIR}/distro/incus.tar.xz" ]; then
            pushd "${SRCDIR}/distro"
            sed -e "s/%RELEASE%/${OS_VERSION}/g" <almalinux.yaml.tmpl >almalinux.yaml
            sudo /var/lib/snapd/snap/bin/distrobuilder build-dir \
                almalinux.yaml \
                rootfs_almalinux_${OS_VERSION} \
                -o image.architecture=s390x \
                -o image.release=${OS_VERSION} \
                -o image.variant=default \
                -o source.variant=boot
            sudo /var/lib/snapd/snap/bin/distrobuilder pack-incus \
                almalinux.yaml \
                rootfs_almalinux_${OS_VERSION} \
                --compression=xz \
                -o image.architecture=s390x \
                -o image.release=${OS_VERSION}  \
                -o image.variant=default \
                -o source.variant=boot
            lxc image import incus.tar.xz rootfs.squashfs --alias almalinux-${OS_VERSION}
            popd
            if [ $? -ne 0 ]; then
                echo "Container build failed" >&2
                exit 2
            fi
        fi
        LXD_CONTAINER="${OS_NAME}-${OS_VERSION}"
        DOTNET_SDK=""
        BUILD_HOME="/root"
        ;;
    *)
        "Unsupported architecture: ${ARCH}"
        exit 1
        ;;
esac
run "$@"
exit $?
