#!/bin/bash

# Source the helpers for use with the script
source $HELPER_SCRIPTS/etc-environment.sh
source $HELPER_SCRIPTS/install.sh
source $HELPER_SCRIPTS/os.sh

if [[ "$ARCH" == "ppc64le" || "$ARCH" == "s390x" ]]; then 
    echo "Installing dotnet for architecture: $ARCH"
    dnf install -y -q dotnet-sdk-8.0
else
    extract_dotnet_sdk() {
        local archive_name=$1

        set -e
        destination="./tmp-$(basename -s .tar.gz $archive_name)"

        echo "Extracting $archive_name to $destination"
        mkdir "$destination" && tar -C "$destination" -xzf "$archive_name"
        rsync -qav --remove-source-files "$destination/shared/" /usr/share/dotnet/shared/
        rsync -qav --remove-source-files "$destination/host/" /usr/share/dotnet/host/
        rsync -qav --remove-source-files "$destination/sdk/" /usr/share/dotnet/sdk/
        rm -rf "$destination" "$archive_name"
    }

    # Variables
    latest_dotnet_packages=$(get_toolset_value '.dotnet.rpmPackages[]')
    dotnet_versions=$(get_toolset_value '.dotnet.versions[]')
    dotnet_tools=$(get_toolset_value '.dotnet.tools[].name')

    # Disable telemetry
    export DOTNET_CLI_TELEMETRY_OPTOUT=1

    # Add Microsoft repository for .NET SDK
    sudo dnf install -y https://packages.microsoft.com/config/rhel/9/packages-microsoft-prod.rpm

    # Give Microsoft's repo higher priority
    cat <<EOF | sudo tee /etc/yum.repos.d/microsoft-prod.repo
[packages-microsoft-com-prod]
name=Microsoft Prod
baseurl=https://packages.microsoft.com/yumrepos/microsoft-rhel9-prod
enabled=1
gpgcheck=1
gpgkey=https://packages.microsoft.com/keys/microsoft.asc
priority=1
EOF

    # Update package list
    sudo dnf update -y

    # Install .NET SDK RPM packages
    for latest_package in ${latest_dotnet_packages[@]}; do
        echo "Determining if .NET Core ($latest_package) is installed"
        if ! rpm -q $latest_package &> /dev/null; then
            echo "Could not find .NET Core ($latest_package), installing..."
            sudo dnf install -y $latest_package
        else
            echo ".NET Core ($latest_package) is already installed"
        fi
    done

    # Remove custom repo priority
    sudo rm -f /etc/yum.repos.d/microsoft-prod.repo
    sudo dnf update -y

    # Install .NET SDK from home repository
    sdks=()
    for version in ${dotnet_versions[@]}; do
        release_url="https://dotnetcli.blob.core.windows.net/dotnet/release-metadata/${version}/releases.json"
        releases=$(cat "$(download_with_retry "$release_url")")
        if [[ $version == "6.0" ]]; then
            sdks=("${sdks[@]}" $(echo "${releases}" | jq -r 'first(.releases[].sdks[]?.version | select(contains("preview") or contains("rc") | not))'))
        else
            sdks=("${sdks[@]}" $(echo "${releases}" | jq -r '.releases[].sdk.version | select(contains("preview") or contains("rc") | not)'))
            sdks=("${sdks[@]}" $(echo "${releases}" | jq -r '.releases[].sdks[]?.version | select(contains("preview") or contains("rc") | not)'))
        fi
    done

    sorted_sdks=$(echo ${sdks[@]} | tr ' ' '\n' | sort -r | uniq -w 5)

    export -f download_with_retry
    export -f extract_dotnet_sdk

    parallel --jobs 0 --halt soon,fail=1 \
        'url="https://dotnetcli.blob.core.windows.net/dotnet/Sdk/{}/dotnet-sdk-{}-linux-x64.tar.gz"; \
        download_with_retry $url' ::: "${sorted_sdks[@]}"

    find . -name "*.tar.gz" | parallel --halt soon,fail=1 'extract_dotnet_sdk {}'

    # Environment variables for .NET
    echo 'DOTNET_SKIP_FIRST_TIME_EXPERIENCE=1' | sudo tee -a /etc/environment
    echo 'DOTNET_NOLOGO=1' | sudo tee -a /etc/environment
    echo 'DOTNET_MULTILEVEL_LOOKUP=0' | sudo tee -a /etc/environment
    echo 'PATH="$HOME/.dotnet/tools:$PATH"' | sudo tee -a /etc/environment

    # Install .NET tools
    for dotnet_tool in ${dotnet_tools[@]}; do
        echo "Installing dotnet tool $dotnet_tool"
        dotnet tool install $dotnet_tool --tool-path '/etc/skel/.dotnet/tools'
    done

fi
