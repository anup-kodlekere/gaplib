#!/bin/bash

header() {
    TS=`date +"%Y-%m-%dT%H:%M:%S%:z"`
    echo "${TS} +--------------------------------------------+"
    echo "${TS} | $*"
    echo "${TS} +--------------------------------------------+"
    echo
}

msg() {
    echo `date +"%Y-%m-%dT%H:%M:%S%:z"` $*
}

patch_runner() {
    header "Cloning repo and Patching runner"
    cd /tmp
    git clone -q ${RUNNERREPO}
    cd runner
    git checkout main -b build
    git apply /var/tmp/imagegeneration/runner-sdk-8.patch
    sed -i'' -e /version/s/8......\"$/8.0.100\"/ src/global.json
    return $?
}

build_runner() {
    export DOTNET_NUGET_SIGNATURE_VERIFICATION=false
    header "Building runner binary"
    cd src

    msg "dev layout"
    ./dev.sh layout Release

    if [ $? -eq 0 ]; then
        msg "dev package"
        ./dev.sh package Release

        if [ $? -eq 0 ]; then
            msg "Finished building runner binary"

            msg "Running tests"
            ./dev.sh test Release
        fi
    fi

    return $?
}

install_runner() {
    header "Installing runner"
    sudo mkdir -p /opt/runner 
    sudo tar -xf /tmp/runner/_package/*.tar.gz -C /opt/runner
    if [ $? -eq 0 ]; then
        sudo chown  runner:runner -R /opt/runner
        sudo -u  runner /opt/runner/config.sh --version
    fi
    return $?
}

pre_cleanup() {
    sudo rm -rf /tmp/runner /opt/runner
}

post_cleanup() {
    sudo rm -rf /imagegeneration/runner-sdk-8.patch \
           /tmp/preseed-yaml /home/ubuntu/.nuget \
           /home/runner/.local/share
}

run() {
    pre_cleanup
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
    post_cleanup
    return ${RC}
}

ARCH=`uname -m`
RUNNERREPO="https://github.com/actions/runner"
while getopts "a:" opt
do
    case ${opt} in
        a)
            RUNNERREPO=${OPTARG}
            ;;
        *)
            exit 4
            ;;
    esac
done
shift $(( OPTIND - 1 ))

run "$@"
exit $?