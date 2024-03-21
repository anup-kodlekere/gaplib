#!/bin/bash

retrieve_dotnet_pkgs() {
    echo "Retrieving dotnet packages"
    pushd /tmp >/dev/null
    for pkg in ${PKGS}
    do
    	RPM="${pkg}.${ARCH}.rpm"
    	wget -q ${MIRROR}/${RPM}
    	if [ ${ID} == "ubuntu" ]; then
            echo -n "Converting ${RPM}... "
            alien -d ${RPM} |& grep -v ^warning
            if [ $? -ne 0 ]; then
                exit 2
            fi
            rm -f ${RPM}
        fi
    done

    echo "Installing dotnet packages"
    dpkg --install /tmp/*.deb
    rm -rf /tmp/*.deb
}

. /etc/os-release
DOTNET_VERSIONS="6 7 8"
ARCH=`uname -m`
MIRROR="https://mirror.lchs.network/pub/almalinux/9.3/AppStream/${ARCH}/os/Packages"

if [ "${ARCH}" == "ppc64le" ]; then
    DOTNET_VERSIONS="8"
elif [ "${ARCH}" == "s390x" ]; then
    DOTNET_VERSIONS="7 8"
else
    DOTNET_VERSIONS="6 7 8"
fi

for dotnetver in ${DOTNET_VERSIONS}
do
case "${dotnetver}" in
    8)
        PKGS="dotnet-apphost-pack-8.0-8.0.1-1.el9_3 dotnet-host-8.0.1-1.el9_3"
        PKGS="${PKGS} dotnet-hostfxr-8.0-8.0.1-1.el9_3 dotnet-targeting-pack-8.0-8.0.1-1.el9_3"
        PKGS="${PKGS} dotnet-templates-8.0-8.0.101-1.el9_3 dotnet-runtime-8.0-8.0.1-1.el9_3"
        PKGS="${PKGS} dotnet-sdk-8.0-8.0.101-1.el9_3 aspnetcore-runtime-8.0-8.0.1-1.el9_3"
        PKGS="${PKGS} aspnetcore-targeting-pack-8.0-8.0.1-1.el9_3 netstandard-targeting-pack-2.1-8.0.101-1.el9_3"
	retrieve_dotnet_pkgs
        ;;
    7)
        PKGS="dotnet-apphost-pack-7.0-7.0.15-1.el9_3 dotnet-host-8.0.1-1.el9_3"
        PKGS="${PKGS} dotnet-hostfxr-7.0-7.0.15-1.el9_3 dotnet-targeting-pack-7.0-7.0.15-1.el9_3"
        PKGS="${PKGS} dotnet-templates-7.0-7.0.115-1.el9_3 dotnet-runtime-7.0-7.0.15-1.el9_3"
        PKGS="${PKGS} dotnet-sdk-7.0-7.0.115-1.el9_3 aspnetcore-runtime-7.0-7.0.15-1.el9_3"
        PKGS="${PKGS} aspnetcore-targeting-pack-7.0-7.0.15-1.el9_3 netstandard-targeting-pack-2.1-8.0.101-1.el9_3"
	retrieve_dotnet_pkgs
        ;;
    6)
        PKGS="dotnet-host-8.0.1-1.el9_3 dotnet-apphost-pack-6.0-6.0.26-1.el9_3"
        PKGS="${PKGS} dotnet-hostfxr-6.0-6.0.26-1.el9_3 dotnet-targeting-pack-6.0-6.0.26-1.el9_3"
        PKGS="${PKGS} dotnet-templates-6.0-6.0.126-1.el9_3 dotnet-runtime-6.0-6.0.26-1.el9_3"
        PKGS="${PKGS} dotnet-sdk-6.0-6.0.126-1.el9_3 aspnetcore-runtime-6.0-6.0.26-1.el9_3"
        PKGS="${PKGS} aspnetcore-targeting-pack-6.0-6.0.26-1.el9_3 netstandard-targeting-pack-2.1-8.0.101-1.el9_3"
	retrieve_dotnet_pkgs
        ;;
    *)
        echo "Unsupported DOTNET version ${dotnetver}" >&2
        exit 1
        ;;
esac
done

echo "List all installed .NET SDKs - `dotnet --list-sdks`"

exit 0

