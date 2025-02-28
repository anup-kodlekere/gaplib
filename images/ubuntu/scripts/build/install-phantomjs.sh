#!/bin/bash -e
################################################################################
##  File:  install-phantomjs.sh
##  Desc:  Install PhantomJS
################################################################################
# Source the helpers for use with the script
source $HELPER_SCRIPTS/install.sh

if [[ "$ARCH" == "ppc64le" ]] ; then 
    update_dpkgs
    install_dpkgs build-essential g++ flex bison gperf \
            ruby perl libsqlite3-dev libfontconfig1-dev libicu-dev \
            libfreetype6 libssl-dev libpng-dev libjpeg-dev python \
            libx11-dev libxext-dev git
    install_dpkgs "^libxcb.*" libx11-xcb-dev libglu1-mesa-dev libxrender-dev libxi-dev

    # Clone PhantomJS code and build it.
    wrkdir=`/tmp`
    cd $wrkdir
    git clone http://github.com/ariya/phantomjs.git
    cd phantomjs && git checkout 2.1.1 && \
    git submodule init && git submodule update && ./build.py -c
    echo "phantomjs build completed."

    # Start automated tests.
    echo "starting tests"
    cd $wrkdir/phantomjs && cd test && python run-tests.py
elif [[ "$ARCH" == "s390x" ]]; then
    # Placeholder for s390x-specific logic
    echo "No actions defined for s390x architecture."
else
    # Install required dependencies
    install_dpkgs chrpath libssl-dev libxft-dev libfreetype6 libfreetype6-dev libfontconfig1 libfontconfig1-dev

    # Define the version and hash of PhantomJS to be installed
    DIR_NAME=phantomjs-2.1.1-linux-x86_64
    ARCHIVE_HASH="86dd9a4bf4aee45f1a84c9f61cf1947c1d6dce9b9e8d2a907105da7852460d2f"

    # Download the archive and verify its integrity using checksum comparison
    download_url="https://bitbucket.org/ariya/phantomjs/downloads/$DIR_NAME.tar.bz2"
    archive_path=$(download_with_retry "$download_url")
    use_checksum_comparison "$archive_path" "$ARCHIVE_HASH"

    # Extract the archive and create a symbolic link to the executable
    tar xjf "$archive_path" -C /usr/local/share
    ln -sf /usr/local/share/$DIR_NAME/bin/phantomjs /usr/local/bin
fi




