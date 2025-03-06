#!/bin/bash -e
################################################################################
##  File:  install-mysql.sh
##  Desc:  Install MySQL Client
################################################################################
# Source the helpers for use with the script
source $HELPER_SCRIPTS/os.sh
source $HELPER_SCRIPTS/install.sh

# Mysql setting up root password
MYSQL_ROOT_PASSWORD=root
echo "mysql-server mysql-server/root_password password $MYSQL_ROOT_PASSWORD" | debconf-set-selections
echo "mysql-server mysql-server/root_password_again password $MYSQL_ROOT_PASSWORD" | debconf-set-selections

export ACCEPT_EULA=Y

# Install MySQL Client
install_dpkgs mysql-client

# Install MySQL Server
install_dpkgs mysql-server

# Install MySQL Dev tools
install_dpkgs libmysqlclient-dev

# Disable mysql.service
systemctl is-active --quiet mysql.service && systemctl stop mysql.service
systemctl disable mysql.service
