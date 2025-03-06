#!/bin/bash -e
################################################################################
##  File:  configure-image-data.sh
##  Desc:  Create a file with image data and documentation links
################################################################################
imagedata_file=$IMAGEDATA_FILE
image_version=$IMAGE_VERSION
image_version_major=${image_version/.*/} # Extract the major version
image_version_minor=$(echo $image_version | cut -d "." -f 2) # Extract the minor version

# Determine OS name and version for CentOS
os_name=$(cat /etc/redhat-release | sed "s/ /\\\n/g") # Get OS name
os_version=$(rpm -E %{rhel}) # Get CentOS version
image_label="centos-${os_version}" # Set image label

# Construct documentation and release URLs
github_url="https://github.com/actions/runner-images/blob"
software_url="${github_url}/centos${os_version}/${image_version_major}.${image_version_minor}/images/centos/CentOS${os_version}-Readme.md"
releaseUrl="https://github.com/actions/runner-images/releases/tag/centos${os_version}%2F${image_version_major}.${image_version_minor}"

# Create the image data JSON file
cat <<EOF > $imagedata_file
[
  {
    "group": "Operating System",
    "detail": "${os_name}"
  },
  {
    "group": "Runner Image",
    "detail": "Image: ${image_label}\nVersion: ${image_version}\nIncluded Software: ${software_url}\nImage Release: ${releaseUrl}"
  }
]
EOF
