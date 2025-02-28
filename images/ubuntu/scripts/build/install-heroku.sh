#!/bin/bash -e
################################################################################
##  File:  install-heroku.sh
##  Desc:  Install Heroku CLI. Based on instructions found here: https://devcenter.heroku.com/articles/heroku-cli
################################################################################
# Source the helpers for use with the script
source $HELPER_SCRIPTS/install.sh

if [[ "$ARCH" == "ppc64le" ]]; then 
    # Placeholder for ppc64le-specific logic
    echo "No actions defined for ppc64le architecture."
elif [[ "$ARCH" == "s390x" ]]; then
    # Placeholder for s390x-specific logic
    echo "No actions defined for s390x architecture."
else
    REPO_URL="https://cli-assets.heroku.com/channels/stable/apt"
    GPG_KEY="/usr/share/keyrings/heroku.gpg"
    REPO_PATH="/etc/apt/sources.list.d/heroku.list"

    # add heroku repository to apt
    curl -fsSL "${REPO_URL}/release.key" | gpg --dearmor -o $GPG_KEY
    echo "deb [trusted=yes] $REPO_URL ./" > $REPO_PATH

    # install heroku
    update_dpkgs
    install_dpkgs heroku

    # remove heroku's apt repository
    rm $REPO_PATH
    rm $GPG_KEY
fi
