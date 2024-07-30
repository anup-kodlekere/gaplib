#!/bin/bash
. /etc/os-release
SDK=$1
ARCH=$(uname -m)
MIRROR=https://mirror.lchs.network/pub/almalinux/9/AppStream/${ARCH}/os/Packages
PKGS_HTML=$(wget --output-document=- "$MIRROR")
PKG_NAMES=(
    "dotnet-apphost-pack-${SDK}"
    "dotnet-host-8"
    "dotnet-hostfxr-${SDK}"
    "dotnet-targeting-pack-${SDK}"
    "dotnet-templates-${SDK}"
    "dotnet-runtime-${SDK}"
    "dotnet-sdk-${SDK}"
    "aspnetcore-runtime-${SDK}"
    "aspnetcore-targeting-pack-${SDK}"
    "netstandard-targeting-pack-2.1-8"
)
RPMS=()
for PKG_NAME in "${PKG_NAMES[@]}"; do
    if [[ "$PKGS_HTML" =~ \"("$PKG_NAME"[^\"]*.rpm)\" ]]; then
        RPM=${BASH_REMATCH[1]}
        echo "Found $RPM"
        RPMS+=("$RPM")
    else
        echo "$PKG_NAME not found" >&2
        exit 1
    fi
done
echo "Retrieving dotnet packages"
pushd /tmp >/dev/null || exit 1
for RPM in "${RPMS[@]}"
do
    wget "${MIRROR}/${RPM}" || exit 1
    if [ "${ID}" == "ubuntu" ]; then
        echo -n "Converting ${RPM}... "
        if ! alien -d "${RPM}" |& grep -v -e ^warning -e ^Unpacking; then
            exit 2
        fi
        rm -f "${RPM}"
    fi
done
