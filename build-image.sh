#!/bin/bash

WORKING_DIR="/home/ubuntu/remote-build"

setup_dotnet_sdk() {
  export DOTNET_SDK_FILE="${WORKING_DIR}/dotnet-sdk-7.0.100-linux-ppc64le.tar.gz"
  export DOTNET_ROOT="/opt/dotnet"
  export PATH=$PATH:$DOTNET_ROOT 
  mkdir -p $DOTNET_ROOT
  tar xf $DOTNET_SDK_FILE -C $DOTNET_ROOT

  echo 'export DOTNET_ROOT=/opt/dotnet' >> /home/ubuntu/.bashrc
  echo 'export PATH=$PATH:$DOTNET_ROOT' >> /home/ubuntu/.bashrc

  # fix ownership
  sudo chown ubuntu:ubuntu /home/ubuntu/.bashrc
  sudo chown ubuntu:ubuntu -R $DOTNET_ROOT

  dotnet --version
  
}

patch_runner() {
  echo "Patching runner"
  cd /tmp
  git clone -q https://github.com/actions/runner
  cd runner
  git checkout $(git describe --tags $(git rev-list --tags --max-count=1))
  git apply "${WORKING_DIR}/files/runner-ppc64le-final.patch"
  
  #TODO: Check if patch is applied correctly
}

build_runner() {
  echo "Building runner binary"
  cd src
  ./dev.sh build 
  ./dev.sh layout
  ./dev.sh package 
  echo "Finished building runner binary"
}

install_runner() {
  echo "Installing runner"
  mkdir -p /opt/runner 
  tar xf ../_package/*.tar.gz -C /opt/runner
  sudo chown ubuntu:ubuntu -R /opt/runner

  su -c "/opt/runner/config.sh --version" ubuntu
  #TODO: Verify that the version is the _actual_ latest runner
}

run() {
  setup_dotnet_sdk
  patch_runner
  build_runner
  install_runner
}

run "$@"
