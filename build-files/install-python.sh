#!/bin/bash

PYTHON_VERSIONS="3.8.18 3.10.13 3.12.1"

for pyver in ${PYTHON_VERSIONS}
do
    export PYTHON_VERSION=${pyver}
    export PYTHON_MAJOR=${PYTHON_VERSION%.*.*}
    wget https://www.python.org/ftp/python/${PYTHON_VERSION}/Python-${PYTHON_VERSION}.tgz
    tar -xzf Python-${PYTHON_VERSION}.tgz
    cd Python-${PYTHON_VERSION}
    ./configure --prefix=/opt/runner/_work/_tool/Python/${PYTHON_VERSION}/ppc64le --enable-shared --enable-optimizations --enable-ipv6 LDFLAGS=-Wl,-rpath=/opt/runner/_work/_tool/Python/${PYTHON_VERSION}/ppc64le/lib,--disable-new-dtags
    make -j$(nproc)
    sudo make install
    sudo touch /opt/runner/_work/_tool/Python/${PYTHON_VERSION}/ppc64le.complete
    sudo ln -s /opt/runner/_work/_tool/Python/${PYTHON_VERSION}/ppc64le/bin/python${PYTHON_MAJOR} /opt/runner/_work/_tool/Python/${PYTHON_VERSION}/ppc64le/bin/python
    cd ..
    rm -rf Python-${PYTHON_VERSION} Python-${PYTHON_VERSION}.tgz
done








