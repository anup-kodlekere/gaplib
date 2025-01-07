#!/bin/bash -e
################################################################################
##  File:  install-mongodb.sh
##  Desc:  Install Mongo DB
################################################################################
# Source the helpers
source $HELPER_SCRIPTS/install.sh
dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')"

if [[ "$ARCH" == "ppc64le" ]] ; then 
    toolset_version=$(get_toolset_value '.mongodb.version')
    REPO_URL="https://repo.mongodb.org/apt/ubuntu"
    GPG_KEY="/usr/share/keyrings/mongodb-org-$toolset_version.gpg"
    REPO_PATH="/etc/apt/sources.list.d/mongodb-org-$toolset_version.list"

    # add Mongo DB repository to apt
    curl -fsSL https://www.mongodb.org/static/pgp/server-$toolset_version.asc | gpg --dearmor -o $GPG_KEY
    echo "deb [ arch=$dpkgArch signed-by=$GPG_KEY ] $REPO_URL $(lsb_release -cs)/mongodb-org/$toolset_version multiverse" > $REPO_PATH

    # Install Mongo DB
    sudo apt-get update
    sudo apt-get install mongodb-org

    # remove Mongo DB's apt repository
    rm $REPO_PATH
    rm $GPG_KEY

    # Document source repo
    echo "mongodb $REPO_URL" >> $HELPER_SCRIPTS/apt-sources.txt
elif [[ "$ARCH" == "s390x" ]]; then
    # Placeholder for s390x-specific logic
    echo "No actions defined for s390x architecture."
else
    toolset_version=$(get_toolset_value '.mongodb.version')
    REPO_URL="https://repo.mongodb.org/apt/ubuntu"
    GPG_KEY="/usr/share/keyrings/mongodb-org-$toolset_version.gpg"
    REPO_PATH="/etc/apt/sources.list.d/mongodb-org-$toolset_version.list"

    # add Mongo DB repository to apt
    curl -fsSL https://www.mongodb.org/static/pgp/server-$toolset_version.asc | gpg --dearmor -o $GPG_KEY
    echo "deb [ arch=amd64,arm64, signed-by=$GPG_KEY ] $REPO_URL $(lsb_release -cs)/mongodb-org/$toolset_version multiverse" > $REPO_PATH

    # Install Mongo DB
    sudo apt-get update
    sudo apt-get install mongodb-org

    # remove Mongo DB's apt repository
    rm $REPO_PATH
    rm $GPG_KEY

    # Document source repo
    echo "mongodb $REPO_URL" >> $HELPER_SCRIPTS/apt-sources.txt
fi
