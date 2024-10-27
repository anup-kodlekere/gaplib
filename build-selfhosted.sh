#!/bin/bash
usage() {
    echo "Usage: build-standalone.sh [flags] [ubuntu|almalinux]"
    echo
    echo "Where flags:"
    echo "-b [docker|podman]           Image build tool to use - defaults to which it finds first"
    echo "-h                           Display this usage information"
    echo
    echo "If no distribution is specified then images for both are built"
    exit
}

ARCH=`uname -m`
DISTROS=""
BUILDER=`which podman 2>/dev/null`
if [ -z ${BUILDER} ]; then
    BUILDER=`which docker 2>/dev/null`
fi
if [ -z ${BUILDER} ]; then
    echo "Need podman or docker installed" >&2
    exit 1
fi
while getopts "b:h:" opt
do
    case "${opt}" in
        b)
            BUILDER="${OPTARG}"
            ;;
        h)
            usage
            ;;
    esac
done
shift $(( OPTIND - 1 ))
if [ -z "$@" ]; then
    DISTROS="ubuntu almalinux"
else
    DISTROS=$@
fi
for dist in ${DISTROS}
do
    if [ ! -f Dockerfile.${dist} ]; then
        echo "${dist} not supported" >&2
    else 
        ${BUILDER} build -f Dockerfile.${dist} --build-arg RUNNERPATCH=build-files/runner-sdk-8.patch \
            --build-arg ARCH=${ARCH} --tag runner:${dist} .
    fi
done
