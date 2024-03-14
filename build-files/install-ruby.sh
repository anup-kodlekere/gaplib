#!/bin/bash

if [ -f /etc/os-release ]; then
    ID=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
    case $ID in
        almalinux|centos|rhel)
            sudo dnf install -y -q wget make gcc-c++ libtool zlib-devel libffi-devel libyaml-devel openssl-devel java-11-openjdk ruby rubygem-rake perl;;
        ubuntu)
            sudo apt-get install -y wget gcc g++ make libtool zlib1g-dev libffi-dev libyaml-dev libssl-dev openjdk-11-jdk ruby;;
        *) exit 0;;
    esac
else
    echo "Unknown OS distribution"
    exit 0
fi

M_ARCH=$(uname -m)
if [ "${M_ARCH}" = "ppc64le" ]; then
    M_ARCH=ppc64
fi

wget -O /tmp/ruby-build-v20240119.tar.gz https://github.com/rbenv/ruby-build/archive/refs/tags/v20240119.tar.gz
cd /tmp
tar -xzf ruby-build-*.tar.gz
sudo PREFIX=/usr/local ./ruby-build-*/install.sh

ruby-build --list| while IFS= read -r line; do
if [[ "$line" != *"picoruby"* ]] && [[ "$line" != *"truffleruby"* ]]; then
  ruby-build $line /opt/runner/_work/_tool/Ruby/$line/${M_ARCH}
  touch /opt/runner/_work/_tool/Ruby/$line/${M_ARCH}.complete
  echo "Installed $line";
fi
done

rm -rf /tmp/ruby-build-v20240119.tar.gz ./ruby-build-*
