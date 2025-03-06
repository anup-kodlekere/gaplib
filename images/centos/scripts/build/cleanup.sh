#!/bin/bash -e
################################################################################
##  File:  cleanup.sh
##  Desc:  Perform cleanup for CentOS
################################################################################

# before cleanup
before=$(df / -Pm | awk 'NR==2{print $4}')

# Clear the local repository of retrieved package files
yum clean all
rm -rf /var/cache/yum/*
rm -rf /tmp/*
rm -rf /root/.cache

# Rotate and vacuum journal logs if `journalctl` is available
if command -v journalctl; then
    journalctl --rotate
    journalctl --vacuum-time=1s
fi

# Delete all .gz and rotated files
find /var/log -type f -regex ".*\.gz$" -delete
find /var/log -type f -regex ".*\.[0-9]$" -delete

# Wipe log files
find /var/log/ -type f -exec cp /dev/null {} \;

# Remove mock binaries for apt
prefix=/usr/local/bin
for tool in apt apt-get apt-key; do
    rm -f $prefix/$tool
done

# after cleanup
after=$(df / -Pm | awk 'NR==2{print $4}')

# Display size
echo "Before: $before MB"
echo "After : $after MB"
echo "Delta : $(($after-$before)) MB"
