#!/bin/bash
set -e  # Exit on any error

HELPERS_DIR="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")/helpers"

source ${HELPERS_DIR}/setup_vars.sh
source ${HELPERS_DIR}/setup_img.sh
source ${HELPERS_DIR}/run_script.sh

BUILD_PREREQS_PATH="$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")"

msg() {
    echo `date +"%Y-%m-%dT%H:%M:%S%:z"` $*
}

if [ ! -d "${BUILD_PREREQS_PATH}" ]; then
  msg "Check the BUILD_PREREQS_PATH specification" >&2
  return 3
fi

if [[ "$IMAGE_OS" == *"ubuntu"* ]]; then
  msg "Copy the apt and dpkg overrides into gha-builder - these prevent doc files from being installed"
  cp -r "${BUILD_PREREQS_PATH}/assets/99synaptics" "/etc/apt/apt.conf.d/99synaptics"
  chmod -R 0644 /etc/apt/apt.conf.d/99synaptics
  cp -r "${BUILD_PREREQS_PATH}/assets/01-nodoc" "/etc/dpkg/dpkg.cfg.d/01-nodoc"
  chmod -R 0644 /etc/dpkg/dpkg.cfg.d/01-nodoc
fi

msg "Copy the register-runner.sh script into gha-builder"
cp -r ${BUILD_PREREQS_PATH}/helpers/register-runner.sh "/opt/register-runner.sh"
chmod -R 0755 /opt/register-runner.sh

msg "Copy the /etc/rc.local - required in case podman is used"
cp -r ${BUILD_PREREQS_PATH}/assets/rc.local "/etc/rc.local"
chmod -R 0755 /etc/rc.local

msg "Copy the gha-service unit file into gha-builder"
cp -r ${BUILD_PREREQS_PATH}/assets/gha-runner.service "/etc/systemd/system/gha-runner.service"
chmod -R 0755 /etc/systemd/system/gha-runner.service

sudo sh -c 'id -u runner >/dev/null 2>&1 || (useradd -c "Action Runner" -m runner && usermod -L runner && echo "runner  ALL=(ALL)       NOPASSWD: ALL" >/etc/sudoers.d/runner)'

sudo sh -c "${HELPER_SCRIPTS}/setup_install.sh ${IMAGE_OS} ${IMAGE_VERSION} ${SETUP}"
