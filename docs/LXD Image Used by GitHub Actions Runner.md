### **LXD Image Used by GitHub Actions Runner**

This section outlines the steps to build the components required for a GitHub-hosted Actions runner using LXD. Follow these instructions to prepare the environment and execute the build process.

---

### **Prerequisites**

1. **Install LXD**  
   - **Via Snap**:  
     Install LXD using Snap with the following command:  
     ```bash
     snap install lxd --classic
     ```
   - **Via APT (Ubuntu)**:  
     Alternatively, install LXD as a package available in the repository:  
     ```bash
     sudo apt update
     sudo apt install lxd
     ```

2. **Initialize LXD**  
   - You can initialize LXD interactively or through a preseed file for automated configuration.  

   **Interactive Initialization:**  
   Run the command and follow the prompts to configure LXD based on your preferences:  
   ```bash
   lxd init
   ```  

   **Automated Initialization:**  
   Create a file named `lxd-preseed.yaml` with the following content to automate the initialization process:  
   ```yaml
   config: {}
   cluster: null
   networks:
     - config:
         ipv4.address: auto
         ipv6.address: auto
       description: "gaplib network"
       name: lxdbr0
       type: ""
   storage_pools:
     - config: {}
       description: "gaplib storage pool"
       name: default
       driver: dir
   profiles:
     - config: {}
       description: "gaplib"
       devices:
         eth0:
           name: eth0
           nictype: bridged
           parent: lxdbr0
           type: nic
         root:
           path: /
           pool: default
           type: disk
       name: default
   ```
   Use the following command to apply the preseed configuration:  
   ```bash
   lxd init --preseed < lxd-preseed.yaml
   ```

---

### **Building the GitHub Actions Runner Image**

After setting up LXD, execute the `lxd.sh` script to build the components for the GitHub Actions runner.  

1. Navigate to the script's directory:  
   ```bash
   cd /path/to/gaplib
   ```

2. Execute the build script:  
   ```
    sudo ./scripts/lxd.sh <os> <version> <setup_type>
   ```
The script will handle the required steps to configure the environment and build the LXD image used by the Actions runner.

---

### **Key Notes**

- Ensure that the required permissions and tools are available before running the script.
- For troubleshooting LXD initialization or network configurations, refer to the [official LXD documentation](https://linuxcontainers.org/lxd/docs/).
