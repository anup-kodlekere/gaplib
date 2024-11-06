#!/bin/bash
header() {
    TS=`date +"%Y-%m-%dT%H:%M:%S%:z"`
    echo "${TS} +--------------------------------------------+"
    echo "${TS} | $*"
    echo "${TS} +--------------------------------------------+"
    echo
}

msg() {
    echo `date +"%Y-%m-%dT%H:%M:%S%:z"` $*
}

# Check if the file name is provided
if [ -z "$1" ]; then
    echo "Usage: $0 <package_list.txt>"
    exit 1
fi

PACKAGE_LIST_FILE=$1

# Check if the file exists
if [ ! -f "$PACKAGE_LIST_FILE" ]; then
    echo "File $PACKAGE_LIST_FILE not found!"
    exit 1
fi
header "Installing additional packages"
# Update the package list
msg "Updating package list..."
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y >/dev/null

# installing docker
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc
do
    sudo apt-get remove $pkg >/dev/null
done

# Add Docker's official GPG key:
sudo DEBIAN_FRONTEND=noninteractive apt-get install ca-certificates curl -y >/dev/null
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Required until docker repo for oracular has ppc64le binaries
case `uname -m` in
    ppc64le)
        REPO="noble"
        ;;
    s390x)
        REPO=$(. /etc/os-release && echo "$VERSION_CODENAME")
        ;;
esac

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  ${REPO} stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list

# Activate the docker repo via update
sudo DEBIAN_FRONTEND=noninteractive apt-get update -y >/dev/null

# Install the docker suite
msg "Installing docker..."
sudo DEBIAN_FRONTEND=noninteractive apt-get install docker-ce docker-ce-cli \
    containerd.io docker-buildx-plugin docker-compose-plugin -y >/dev/null

# Read the file line by line and install each package
OK=`true`
while IFS= read -r package || [ -n "$package" ]; do
    if [[ ! -z "$package" && "$package" != \#* ]]; then
        echo "Installing $package..."
        sudo DEBIAN_FRONTEND=noninteractive apt-get -qq install -y "$package" >/dev/null
        if [ $? -ne 0 ]; then
            OK=`false`
        fi
        sudo dpkg --configure -a
    fi
done < "$PACKAGE_LIST_FILE"

if [ ${OK} ]; then
    msg "All packages from $PACKAGE_LIST_FILE have been installed."
else
    msg "NOT all packages from $PACKAGE_LIST_FILE have been installed - check log."
fi

# Removing the packaging cache
sudo rm -rf /var/cache/apt/archives /var/lib/apt/lists/*
sudo apt-get clean
