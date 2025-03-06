#!/bin/bash -e
################################################################################
##  File:  install-git-lfs.sh
##  Desc:  Install Git-lfs
################################################################################
# Load helper functions (if any)
source $HELPER_SCRIPTS/install.sh

GIT_LFS_REPO="https://packagecloud.io/github/git-lfs/el/9"

# Install git-lfs
curl -fsSL https://packagecloud.io/install/repositories/github/git-lfs/script.rpm.sh | sudo bash
install_dnfpkgs git-lfs

# Remove source repo's
sudo rm -f /etc/yum.repos.d/github_git-lfs.repo

# Document installed Git LFS repo
echo "git-lfs $GIT_LFS_REPO" | sudo tee -a $HELPER_SCRIPTS/package-versions.txt
