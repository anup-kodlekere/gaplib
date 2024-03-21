#!/bin/bash

PYTHON_VERSIONS="3.8.18 3.10.13 3.12.1"
M_ARCH=$(uname -m)

if [ -f /etc/os-release ]; then
    ID=$(grep -oP '(?<=^ID=).+' /etc/os-release | tr -d '"')
    case $ID in
        almalinux|centos|rhel)
            sudo dnf install -y -q wget gcc-c++ make libtool zlib-devel libffi-devel libyaml-devel libxml2-devel libxslt-devel openssl-devel sqlite-devel;;
        ubuntu)
            sudo apt-get install -y wget gcc g++ make libtool zlib1g-dev libffi-dev libyaml-dev libxml2-dev libxslt1-dev libssl-dev libsqlite3-dev;;
        *)
            echo "This OS is not supported."
            exit 1;;
    esac
else
    echo "Unknown OS distribution."
    exit 1
fi

for pyver in ${PYTHON_VERSIONS}
do
    export PYTHON_VERSION=${pyver}
    export PYTHON_MAJOR=${PYTHON_VERSION%.*.*}
    wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
    tar -xzf Python-${PYTHON_VERSION}.tgz
    cd Python-${PYTHON_VERSION}
    ./configure --prefix=/opt/runner/_work/_tool/Python/${PYTHON_VERSION}/${M_ARCH} --enable-shared --enable-optimizations --enable-ipv6 --enable-loadable-sqlite-extensions LDFLAGS=-Wl,-rpath=/opt/runner/_work/_tool/Python/${PYTHON_VERSION}/${M_ARCH}/lib,--disable-new-dtags
    make -j$(nproc)
    sudo make install
    sudo touch /opt/runner/_work/_tool/Python/${PYTHON_VERSION}/${M_ARCH}.complete
    sudo ln -s /opt/runner/_work/_tool/Python/${PYTHON_VERSION}/${M_ARCH}/bin/python${PYTHON_MAJOR} /opt/runner/_work/_tool/Python/${PYTHON_VERSION}/${M_ARCH}/bin/python
    sudo ln -s /opt/runner/_work/_tool/Python/${PYTHON_VERSION}/${M_ARCH}/bin/pip${PYTHON_MAJOR} /opt/runner/_work/_tool/Python/${PYTHON_VERSION}/${M_ARCH}/bin/pip
    cd ..
    rm -rf Python-${PYTHON_VERSION} Python-${PYTHON_VERSION}.tgz
done

