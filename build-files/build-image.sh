#!/bin/bash

update_fresh_container() {
    echo "Upgrading and installing packages"
    sudo DEBIAN_FRONTEND=noninteractive apt-get -qq update -y
    sudo DEBIAN_FRONTEND=noninteractive apt-get -qq install alien libicu70 -y

    if [ $? -ne 0 ]; then
        exit 32
    fi
    sudo apt autoclean

    sudo sed "s/--no-absolute-filenames//" /usr/share/perl5/Alien/Package/Rpm.pm > /tmp/Rpm.pm
    sudo cp /tmp/Rpm.pm /usr/share/perl5/Alien/Package/Rpm.pm

    echo "Initializing LXD environment"
    sudo lxd init --preseed </tmp/lxd-preseed.yaml

    echo "Make sure we have lxd authority"
    sudo usermod -G lxd -a ubuntu
}

setup_dotnet_sdk() {
    MIRROR="https://mirror.lchs.network/pub/almalinux/9/AppStream/${ARCH}/os/Packages"
    case "${SDK}" in 
        8)
            PKGS="dotnet-apphost-pack-8.0-8.0.4-2.el9_4 dotnet-host-8.0.4-2.el9_4"
            PKGS="${PKGS} dotnet-hostfxr-8.0-8.0.4-2.el9_4 dotnet-targeting-pack-8.0-8.0.4-2.el9_4"
            PKGS="${PKGS} dotnet-templates-8.0-8.0.104-2.el9_4 ddotnet-runtime-8.0-8.0.4-2.el9_4"
            PKGS="${PKGS} dotnet-sdk-8.0-8.0.104-2.el9_4 aspnetcore-runtime-8.0-8.0.4-2.el9_4"
            PKGS="${PKGS} aspnetcore-targeting-pack-8.0-8.0.4-2.el9_4 netstandard-targeting-pack-2.1-8.0.104-2.el9_4"
            ;;
        7)
            PKGS="dotnet-apphost-pack-7.0-7.0.19-1.el9_4 dotnet-host-8.0.5-1.el9_4"
            PKGS="${PKGS} dotnet-hostfxr-7.0-7.0.19-1.el9_4 dotnet-targeting-pack-7.0-7.0.19-1.el9_4"
            PKGS="${PKGS} dotnet-templates-7.0-7.0.119-1.el9_4 dotnet-runtime-7.0-7.0.19-1.el9_4"
            PKGS="${PKGS} dotnet-sdk-7.0-7.0.119-1.el9_4 aspnetcore-runtime-7.0-7.0.19-1.el9_4"
            PKGS="${PKGS} aspnetcore-targeting-pack-7.0-7.0.19-1.el9_4 netstandard-targeting-pack-2.1-8.0.105-1.el9_4"
            ;;
        *)
            echo "Unsupported architecture ${ARCH}" >&2
            return 1
            ;;
    esac
    echo "Retrieving dotnet packages"
    pushd /tmp >/dev/null
    for pkg in ${PKGS}
    do
        RPM="${pkg}.${ARCH}.rpm"
        wget -q ${MIRROR}/${RPM}
        echo -n "Converting ${RPM}... "
        sudo alien -d ${RPM} |& grep -v ^warning
        if [ $? -ne 0 ]; then
            return 2
        fi
        rm -f ${RPM}
    done

    echo "Installing dotnet"
    sudo DEBIAN_FRONTEND=noninteractive dpkg --install /tmp/*.deb
    if [ $? -ne 0 ]; then
        return 3
    fi
    sudo rm -f /tmp/*.deb
    popd >/dev/null

    if [ ${SDK} -ne 6 ]; then
        pushd /usr/lib64/dotnet/packs >/dev/null
        sudo ln -s Microsoft.AspNetCore.App.Ref Microsoft.AspNetCore.App.Runtime.linux-${ARCH}
        sudo ln -s Microsoft.AspNetCore.App.Ref Microsoft.AspNetCore.App.linux-${ARCH}
        sudo ln -s Microsoft.NETCore.App.Host.rhel.9-${ARCH} Microsoft.NETCore.App.Host.linux-${ARCH}
        sudo ln -s Microsoft.NETCore.App.Ref Microsoft.NETCore.App.Runtime.linux-${ARCH}
        popd >/dev/null
    fi

    echo "Using SDK - `dotnet --version`"

    # fix ownership
    sudo chown ubuntu:ubuntu /home/ubuntu/.bashrc

    sudo chmod +x /etc/rc.local
    sudo systemctl start rc-local

    return 0
}

patch_runner() {
    echo "Patching runner"
    cd /tmp
    git clone -q ${RUNNERREPO}
    cd runner
    git checkout $(git describe --tags $(git rev-list --tags --max-count=1)) -b ${ARCH}
    git apply /home/ubuntu/runner-${ARCH}.patch
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
    rm -rf /home/ubuntu/build-image.sh /home/ubuntu/runner-${ARCH}.patch \
           /tmp/runner /tmp/preseed-yaml
}

run() {
    update_fresh_container
    setup_dotnet_sdk
    RC=$?
    if [ ${RC} -eq 0 ]; then
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
    fi
    cleanup
    return ${RC}
}

export HOME=/home/ubuntu
ARCH=`uname -m`
SDK=""
RUNNERREPO="https://github.com/actions/runner"
while getopts "a:s:" opt
do
    case ${opt} in
        a)
            RUNNERREPO=${OPTARG}
            ;;
        s)
            SDK=${OPTARG}
            ;;
        *)
            exit 4
            ;;
    esac
done
shift $(( OPTIND - 1 ))

if [ -z "${SDK}" ]; then
    case ${ARCH} in
        ppc64le)
            SDK=7
            ;;
        s390x)
            SDK=6
            ;;
    esac
fi

run "$@"
exit $?


