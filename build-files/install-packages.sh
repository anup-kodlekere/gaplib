#!/bin/bash

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

# Update the package list
echo "Updating package list..."
sudo DEBIAN_FRONTEND=noninteractive apt-get -qq update -y

# Read the file line by line and install each package
while IFS= read -r package || [ -n "$package" ]; do
    if [[ ! -z "$package" && "$package" != \#* ]]; then
        echo "Installing $package..."
        sudo DEBIAN_FRONTEND=noninteractive apt-get -qq install -y "$package"
    fi
done < "$PACKAGE_LIST_FILE"

echo "All packages from $PACKAGE_LIST_FILE have been installed."
