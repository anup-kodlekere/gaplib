#!/bin/bash

set -euxo pipefail

BUILDER_TAG=s390x-actions-runner-builder
RUNNER_VERSION=$(cat last_version)

docker buildx build \
       --platform linux/s390x \
       -f Dockerfile.ubuntu \
       --target builder \
       --build-arg RUNNERPATCH=build-files/runner-sdk-8.patch \
       --build-arg RUNNER_VERSION=${RUNNER_VERSION} \
       --tag ${BUILDER_TAG} \
       .

container=$(docker run --platform linux/s390x -d ${BUILDER_TAG} sleep infinity)
docker cp "$container:/tmp/runner/_package/actions-runner-linux-s390x-${RUNNER_VERSION#v}.tar.gz" .
docker stop -t 1 $container

