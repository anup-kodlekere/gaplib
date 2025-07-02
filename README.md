# **DISCLAIMER**:

This repository is now archived in-favor of https://github.com/ppc64le/gaplib. Please use that to be on the latest runner images. Thank you!

# **GapLib**

GapLib is a robust collection of setup scripts for configuring custom GitHub Actions runners. These scripts are designed to seamlessly adapt to updates in `actions/runner`, ensuring compatibility and optimal performance across diverse environments, including **VM (host machine)**, **LXD**, **Docker**, and **Podman**.

This repository also includes source code to create VM images for GitHub-hosted runners widely used in Actions workflows. GapLib supports multiple operating systems and architectures, providing a versatile and scalable solution to meet diverse project requirements.


## **Table of Contents**

- [Overview](#overview)
    - [Supported Environments](#supported-environments)
    - [Supported Architectures](#supported-architectures)
    - [Supported Operating Systems](#supported-operating-systems)
- [Scripts](#scripts)
    - [run.sh](#runsh)
    - [Key Features](#key-features)
- [Usage](#usage)
- [Setup Options](#setup-options)
    - [Main Menu](#main-menu)
    - [OS and Version Selection](#os-and-version-selection)
    - [Minimal or Complete Setup](#minimal-or-complete-setup)
    - [Unsupported Architectures](#unsupported-architectures)
- [Requirements](#requirements)
- [Contributing](#contributing)

---

## **Overview**

### **Supported Environments**

GapLib supports multiple environments for seamless runner setup:

- **VM (host machine)**: Direct setup on virtual or host machines.
- **LXD**: Lightweight container-based virtualization.
- **Docker**: Industry-standard containerization platform.
- **Podman**: Docker-compatible, daemonless container management.

### **Supported Architectures**

- **ppc64le**
- **s390x**
- **x86_64**

### **Supported Operating Systems**

- **Ubuntu**: Versions 22.04, 24.04, and 24.10.
- **CentOS**: Version 9.

---

## **Scripts**

### **run.sh**

`run.sh` is the primary script for setting up GitHub Actions runners. It provides an interactive, menu-driven interface for selecting environments, operating systems, versions, and setup types.

### **Key Features**

- **Interactive Menu**: Guides users through setup options (VM, LXD, Docker, or Podman).
- **Architecture Detection**: Ensures compatibility with supported architectures.
- **Custom OS and Version Selection**: Allows users to tailor setup to specific environments.
- **Setup Type Options**: Supports **Minimal** (basic setup) and **Complete** (full setup) configurations.

---

## **Usage**

1. Clone the repository:
    
    
2. Execute the setup script:
    
    ```bash
    bash run.sh
    
    ```
    
3. Follow the prompts to:
    - Select your environment (**VM**, **LXD**, **Docker**, or **Podman**).
    - Choose your OS and version.
    - Specify the setup type (**Minimal** or **Complete**).

---

## **Setup Options**

### **Main Menu**

The script provides the following main options:

```
1. VM (host machine)
2. LXD
3. Docker
4. Podman
5. Exit

```

Select an option to proceed with the setup.

### **OS and Version Selection**

Choose your preferred operating system and version (Ubuntu or CentOS). If a version is not specified, the script will prompt you for a selection.

### **Minimal or Complete Setup**

- **Minimal Setup**: Installs only the essential components.
- **Complete Setup**: Performs a full installation with additional configurations.

### **Unsupported Architectures**

If the script encounters an unsupported architecture, it will provide these options:

```
1. Return to the previous step
2. Exit

```

---

## **Requirements**

- **Bash Shell**: Required to execute the scripts.
- **Sudo Privileges**: Necessary for certain setup tasks depending on the environment.

---

## **Contributing**

We welcome contributions to enhance GapLib. Here's how you can help:

1. Fork the repository.
2. Create a new branch for your changes.
3. Submit a pull request with detailed information about your updates.

For suggestions, bug reports, or questions, feel free to open an issue in the repository.

---

### **Why Choose GapLib?**

With support for multiple architectures, operating systems, and containerized environments, GapLib simplifies and streamlines the process of configuring GitHub Actions runners, making it the go-to solution for diverse project requirements.
