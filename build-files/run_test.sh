#!/bin/bash
patch_runner() {
    echo "Patching runner"
    cd /tmp
    git clone -q ${RUNNERREPO}
    cd runner
    git checkout $(git describe --tags $(git rev-list --tags --max-count=1)) -b ${ARCH}
    git apply /home/ubuntu/runner-${ARCH}-s8.patch
    return $?
}

build_runner() {
    export DOTNET_NUGET_SIGNATURE_VERIFICATION=false
    echo "Building runner binary"
    cd src

    echo "dev layout"
    ./dev.sh layout

    if [ $? -eq 0 ]; then
        echo "dev package"
        ./dev.sh package 

        if [ $? -eq 0 ]; then
            echo "Finished building runner binary"

            echo "Running tests"
            ./dev.sh test
        fi
    fi

    return $?
}

install_runner() {
    echo "Installing runner"
    sudo mkdir -p /opt/runner 
    sudo tar -xf /tmp/runner/_package/*.tar.gz -C /opt/runner
    if [ $? -eq 0 ]; then
        sudo chown ubuntu:ubuntu -R /opt/runner
        /opt/runner/config.sh --version
        #TODO: Verify that the version is the _actual_ latest runner
    fi
    return $?
}

cleanup() {
    sudo rm -rf /home/ubuntu/build-image.sh /home/ubuntu/runner-${ARCH}-s8.patch \
           /tmp/runner /tmp/preseed-yaml /opt/runner
}

run() {
    
    patch_runner
    RC=$?
    if [ ${RC} -eq 0 ]; then
        build_runner
        RC=$?
        if [ ${RC} -eq 0 ]; then
            install_runner
            RC=$?
        fi
    fi
    cleanup
    return ${RC}
}
export HOME=/home/ubuntu
ARCH=`uname -m`
SDK="-s 8"
RUNNERREPO="https://github.com/actions/runner"
run "$@"
exit $?