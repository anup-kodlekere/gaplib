#!/bin/bash
. /etc/os-release
SDK=$1
ARCH=`uname -m`
MIRROR="https://mirror.lchs.network/pub/almalinux/9/AppStream/${ARCH}/os/Packages"
case "${SDK}" in
    8)
        # PKGS="dotnet-apphost-pack-8.0-8.0.4-2.el9_4 dotnet-host-8.0.4-2.el9_4"
        # PKGS="${PKGS} dotnet-hostfxr-8.0-8.0.4-2.el9_4 dotnet-targeting-pack-8.0-8.0.4-2.el9_4"
        # PKGS="${PKGS} dotnet-templates-8.0-8.0.104-2.el9_4 dotnet-runtime-8.0-8.0.4-2.el9_4"
        # PKGS="${PKGS} dotnet-sdk-8.0-8.0.104-2.el9_4 aspnetcore-runtime-8.0-8.0.4-2.el9_4"
        # PKGS="${PKGS} aspnetcore-targeting-pack-8.0-8.0.4-2.el9_4 netstandard-targeting-pack-2.1-8.0.104-2.el9_4"
        # ;;
        PKGS="dotnet-apphost-pack-8.0-8.0.5-1.el9_4 dotnet-host-8.0.5-1.el9_4"
        PKGS="${PKGS} dotnet-hostfxr-8.0-8.0.5-1.el9_4 dotnet-targeting-pack-8.0-8.0.5-1.el9_4"
        PKGS="${PKGS} dotnet-templates-8.0-8.0.105-1.el9_4 dotnet-runtime-8.0-8.0.5-1.el9_4"
        PKGS="${PKGS} dotnet-sdk-8.0-8.0.105-1.el9_4 aspnetcore-runtime-dbg-8.0-8.0.5-1.el9_4"
        PKGS="${PKGS} aspnetcore-targeting-pack-8.0-8.0.5-1.el9_4 netstandard-targeting-pack-2.1-8.0.105-1.el9_4"
        PKGS="${PKGS} dotnet-runtime-dbg-8.0-8.0.5-1.el9_4 dotnet-sdk-dbg-8.0-8.0.105-1.el9_4 aspnetcore-runtime-dbg-8.0-8.0.5-1.el9_4"
        ;;
    7)
        PKGS="dotnet-apphost-pack-7.0-7.0.19-1.el9_4 dotnet-host-8.0.5-1.el9_4"
        PKGS="${PKGS} dotnet-hostfxr-7.0-7.0.19-1.el9_4 dotnet-targeting-pack-7.0-7.0.19-1.el9_4"
        PKGS="${PKGS} dotnet-templates-7.0-7.0.119-1.el9_4 dotnet-runtime-7.0-7.0.19-1.el9_4"
        PKGS="${PKGS} dotnet-sdk-7.0-7.0.119-1.el9_4 aspnetcore-runtime-7.0-7.0.19-1.el9_4"
        PKGS="${PKGS} aspnetcore-targeting-pack-7.0-7.0.19-1.el9_4 netstandard-targeting-pack-2.1-8.0.105-1.el9_4"
        ;;
    # 6)
    #     PKGS="dotnet-host-8.0.1-1.el9_3 dotnet-apphost-pack-6.0-6.0.26-1.el9_3"
    #     PKGS="${PKGS} dotnet-hostfxr-6.0-6.0.26-1.el9_3 dotnet-targeting-pack-6.0-6.0.26-1.el9_3"
    #     PKGS="${PKGS} dotnet-templates-6.0-6.0.126-1.el9_3 dotnet-runtime-6.0-6.0.26-1.el9_3"
    #     PKGS="${PKGS} dotnet-sdk-6.0-6.0.126-1.el9_3 aspnetcore-runtime-6.0-6.0.26-1.el9_3"
    #     PKGS="${PKGS} aspnetcore-targeting-pack-6.0-6.0.26-1.el9_3 netstandard-targeting-pack-2.1-8.0.101-1.el9_3"
    #     ;;
    *)
        echo "Unsupported SDK ${SDK}" >&2
        exit 1
        ;;
esac
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
exit 0
