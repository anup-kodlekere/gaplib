#!/bin/bash -e
################################################################################
##  File:  configure-yum-mock.sh
##  Desc:  A temporary workaround to handle transient issues with DNF/YUM.
##         Cleaned up during cleanup.sh.
################################################################################
prefix=/usr/local/bin

for real_tool in /usr/bin/yum /usr/bin/dnf; do
    tool=$(basename $real_tool)
    cat >$prefix/$tool <<EOT
#!/bin/sh

i=1
while [ \$i -le 30 ];do
  err=\$(mktemp)
  $real_tool "\$@" 2>\$err

  # no errors, break the loop and continue normal flow
  test -f \$err || break
  cat \$err >&2

  retry=false

  if grep -q 'Could not get lock' \$err;then
    # DNF/YUM db locked needs retry
    retry=true
  elif grep -q 'Failed to download metadata' \$err;then
    # Repository metadata issue, needs retry
    retry=true
  elif grep -q 'Temporary failure in name resolution' \$err;then
    # DNS resolution issue
    retry=true
  elif grep -q 'Package is being held by another process' \$err;then
    # DNF/YUM process is busy by another process
    retry=true
  fi

  rm \$err
  if [ \$retry = false ]; then
    break
  fi

  sleep 5
  echo "...retry \$i"
  i=\$((i + 1))
done
EOT
    chmod +x $prefix/$tool
done
