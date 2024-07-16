#!/bin/bash
. /etc/os-release
SDK=$1
ARCH=`uname -m`
MIRROR="https://mirror.lchs.network/pub/almalinux/9/AppStream/${ARCH}/os/Packages"
case "${SDK}" in
    7)
        PKGS="dotnet-apphost-pack-7.0-7.0.19-1.el9_4 dotnet-host-8.0.5-1.el9_4"
        PKGS="${PKGS} dotnet-hostfxr-7.0-7.0.19-1.el9_4 dotnet-targeting-pack-7.0-7.0.19-1.el9_4"
        PKGS="${PKGS} dotnet-templates-7.0-7.0.119-1.el9_4 dotnet-runtime-7.0-7.0.19-1.el9_4"
        PKGS="${PKGS} dotnet-sdk-7.0-7.0.119-1.el9_4 aspnetcore-runtime-7.0-7.0.19-1.el9_4"
        PKGS="${PKGS} aspnetcore-targeting-pack-7.0-7.0.19-1.el9_4 netstandard-targeting-pack-2.1-8.0.105-1.el9_4"
        ;;
    6)
        PKGS="dotnet-host-8.0.5-1.el9_4 dotnet-apphost-pack-6.0-6.0.30-1.el9_4"
        PKGS="${PKGS} dotnet-hostfxr-6.0-6.0.30-1.el9_4 dotnet-targeting-pack-6.0-6.0.30-1.el9_4"
        PKGS="${PKGS} dotnet-templates-6.0-6.0.130-1.el9_4 dotnet-runtime-6.0-6.0.30-1.el9_4"
        PKGS="${PKGS} dotnet-sdk-6.0-6.0.130-1.el9_4 aspnetcore-runtime-6.0-6.0.30-1.el9_4"
        PKGS="${PKGS} aspnetcore-targeting-pack-6.0-6.0.30-1.el9_4 netstandard-targeting-pack-2.1-8.0.105-1.el9_4"
        ;;
    *)
        echo "Unsupported architecture ${ARCH}" >&2
        return 1
        ;;
esac
echo "Retrieving dotnet packages"
if [ ${ID} = "ubuntu" ]; then
    sed -i'' -e 's/--no-absolute-filenames//' /usr/share/perl5/Alien/Package/Rpm.pm
fi
pushd /tmp >/dev/null
for pkg in ${PKGS}
do
    RPM="${pkg}.${ARCH}.rpm"
    wget -q ${MIRROR}/${RPM}
    if [ ${ID} = "ubuntu" ]; then
        echo -n "Converting ${RPM}... "
        alien -d ${RPM} |& grep -v ^warning
        if [ $? -ne 0 ]; then
            return 2
        fi
        rm -f ${RPM}
    fi
done
exit 0
