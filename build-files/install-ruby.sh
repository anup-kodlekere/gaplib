#!/bin/bash

sudo apt-get install -y gcc g++ make zlib1g-dev libffi-dev libtool libyaml-dev libssl-dev openjdk-11-jdk ruby

wget -O /tmp/ruby-build-v20240119.tar.gz https://github.com/rbenv/ruby-build/archive/refs/tags/v20240119.tar.gz
cd /tmp
tar -xzf ruby-build-*.tar.gz
sudo PREFIX=/usr/local ./ruby-build-*/install.sh

ruby-build --list| while IFS= read -r line; do
if [[ "$line" != *"picoruby"* ]] && [[ "$line" != *"truffleruby"* ]]; then
  ruby-build $line /opt/runner/_work/_tool/Ruby/$line/ppc64
  touch /opt/runner/_work/_tool/Ruby/$line/ppc64.complete
  echo "Installed $line";
fi
done

rm -rf /tmp/ruby-build-v20240119.tar.gz ./ruby-build-*

