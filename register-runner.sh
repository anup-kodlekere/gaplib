#!/bin/bash

while getopts r:t:l:n flag
do
    case "${flag}" in
        r) repo=${OPTARG};;
        t) token=${OPTARG};;
        l) label=${OPTARG};;
        n) name=${OPTARG};;
    esac
done

while !(ping -q -c 1 -W 1 google.com >/dev/null)
do
    echo "waiting for internet connectivity..."
    sleep 2
done

cd /opt/runner

# register the runner
export DOTNET_ROOT=/opt/dotnet
export PATH=$PATH:$DOTNET_ROOT
./config.sh \
  --unattended \
  --disableupdate \
  --ephemeral \
  --name "${name}" \
  --labels "${label}" \
  --url "https://github.com/${repo}" \
  --token "${token}"

# start the runner to run job
sudo systemctl daemon-reload
sudo systemctl start gha-runner.service
