#!/bin/bash

# Function to display main menu
display_main_menu() {
    echo "Select the setup type:"
    echo "1. VM (host machine)"
    echo "2. LXD"
    echo "3. Docker"
    echo "4. Podman"
    echo "5. Exit"
}

# Function to handle unsupported architectures
handle_unsupported_arch() {
    echo "ARCH not supported."
    echo "1. Return back to the previous step"
    echo "2. Exit"
    read -rp "Enter your choice: " choice
    if [ "$choice" -eq 1 ]; then
        return 1
    else
        exit 0
    fi
}

# Function to handle OS selection and architecture
handle_os_and_arch() {
    local env=$1
    local os=$2
    local version=$3
    local supported_arch=("ppc64le" "s390x" "x86_64")
    local arch=$(uname -m)

    # Check if the current architecture is supported
    for sa in "${supported_arch[@]}"; do
        if [[ "$arch" == "$sa" ]]; then
            if [[ "$os" == *"centos"* ]]; then
                # Only minimal setup is supported for CentOS
                echo "Only minimal setup is supported for $os $version on $arch."
                echo "Proceeding with minimal setup..."
                # Insert minimal setup script or function here
                sudo sh -c "scripts/${env}.sh ${os} ${version} minimal"
                # echo "${env}.sh ${os} ${version} minimal"
                return 0
            elif [[ "$os" == "ubuntu" ]]; then
                # Check if the environment is docker or podman for minimal setup
                if [[ "$env" == "docker" || "$env" == "podman" ]]; then
                    echo "Only minimal setup is supported for $os $version in $env."
                    # Proceed with minimal setup
                    sudo sh -c "scripts/${env}.sh ${os} ${version} minimal"
                    return 0
                else
                    # Ask the user for minimal or complete setup
                    while true; do
                        echo "Choose setup type for $os $version on $arch:"
                        echo "1. Minimal Setup"
                        echo "2. Complete Setup"
                        echo "3. Return back to main menu"
                        read -rp "Enter your choice: " setup_choice

                        case $setup_choice in
                            1)
                                echo "Proceeding with minimal setup for $os $version."
                                # Insert minimal setup script or function here
                                sudo sh -c "scripts/${env}.sh ${os} ${version} minimal"
                                # echo "${env}.sh ${os} ${version} minimal"
                                return 0
                                ;;
                            2)
                                echo "Proceeding with complete setup for $os $version."
                                # Insert complete setup script or function here
                                sudo sh -c "scripts/${env}.sh ${os} ${version} complete"
                                # echo "${env}.sh ${os} ${version} complete"
                                return 0
                                ;;
                            3)
                                return 1  # Go back to the previous menu
                                ;;
                            *)
                                echo "Invalid choice, please try again."
                                ;;
                        esac
                    done
                fi
            else
                echo "Unsupported OS: $os. Please select a valid OS."
                return 1
            fi
        fi
    done

    # Handle unsupported architecture
    handle_unsupported_arch
    return $?
}


# Function to handle VM setup
setup_env() {
    local env=$1
    local os=$2
    local version=${3:-} # Use the second argument as the version or leave it empty

    if [[ "$os" == *"ubuntu"* || "$os" == *"centos"* ]]; then
        echo "Selected OS: $os"

        # If version is not provided, prompt the user for a choice
        if [[ -z "$version" ]]; then
            echo "Select the OS version:"
            if [[ "$os" == *"ubuntu"* ]]; then
                echo "1. 22.04"
                echo "2. 24.10"
                echo "3. 24.04"
                echo "4. Return back to main menu"
                read -rp "Enter your choice: " version_choice
                case $version_choice in
                1) version="22.04" ;;
                2) version="24.10" ;;
                3) version="24.04" ;;
                4) return ;;
                *) echo "Invalid choice."; setup_env "$env" "$os"; return ;;
                esac
            elif [[ "$os" == *"centos"* ]]; then
                echo "1. 9"
                echo "2. Return back to main menu"
                read -rp "Enter your choice: " version_choice
                case $version_choice in
                1) version="9" ;;
                2) return ;;
                *) echo "Invalid choice."; setup_env "$env" "$os"; return ;;
                esac
            fi
        fi

        # Call handle_os_and_arch with the selected or provided version
        if ! handle_os_and_arch "$env" "$os" "$version"; then
            return
        fi
    else
        echo "OS not supported."
        echo "1. Return back to main menu"
        echo "2. Exit"
        read -rp "Enter your choice: " choice
        case "$choice" in
            1) return ;;
            2) exit 0 ;;
            *) echo "Invalid choice."; ;;
        esac
    fi
}

# Helper Function: Ask OS and call setup_env
ask_os_and_setup_env() { 
    component="$1"
    
    case "$component" in
        "docker" | "podman")
            while true; do
                echo "Please select the OS for $component setup:"
                echo "1. Ubuntu"
                echo "2. CentOS/Almalinux"
                echo "3. Return back to the previous step"
                read -rp "Enter choice: " os_choice
                case $os_choice in
                    1) setup_env "$component" "ubuntu"; break ;;  # Pass the OS as argument to setup_env
                    2) setup_env "$component" "centos"; break ;;  # Pass the OS as argument to setup_env
                    3) return ;;                    # Return to the previous menu
                    *)
                        echo "Invalid choice. Please try again."
                        ;;
                esac
            done
            ;;
        "lxd")
            while true; do
                echo "Please select the OS for $component setup:"
                echo "1. Ubuntu"
                echo "2. Return back to the previous step"
                read -rp "Enter choice: " os_choice
                case $os_choice in
                    1) setup_env "$component" "ubuntu"; break ;;  # Pass the OS as argument to setup_env
                    2) return ;;                    # Return to the previous menu
                    *)
                        echo "Invalid choice. Please try again."
                        ;;
                esac
            done
            ;;
        *)
            echo "Unsupported component: $component"
            return ;;
    esac
}

# Main script loop
while true; do
    display_main_menu
    read -rp "Enter your choice: " main_choice
    case $main_choice in
    1)
        setup_env "vm" $(awk -F= '/^NAME/{print $2}' /etc/os-release | tr -d '"' | tr '[:upper:]' '[:lower:]' | awk '{print $1}') $(cat /etc/os-release | grep -E 'VERSION_ID' | cut -d'=' -f2 | tr -d '"')
        ;;
    2)
        ask_os_and_setup_env "lxd"
        ;;
    3)
        ask_os_and_setup_env "docker"
        ;;
    4)
        ask_os_and_setup_env "podman"
        ;;
    5)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid choice."
        ;;
    esac
done
