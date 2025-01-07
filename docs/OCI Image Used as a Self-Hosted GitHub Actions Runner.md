### **OCI Image Used as a Self-Hosted GitHub Actions Runner**

A **self-hosted runner** is a system you deploy and manage to execute jobs from GitHub Actions workflows on GitHub.com. This document outlines the steps to build and configure an OCI image for a self-hosted runner.  

#### **Additional Resources**  
Refer to GitHub's official documentation on self-hosted runners for detailed information:  
- [About Self-Hosted Runners](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/about-self-hosted-runners)  
- [Adding a Self-Hosted Runner](https://docs.github.com/en/actions/hosting-your-own-runners/managing-self-hosted-runners/adding-self-hosted-runners)  
- [Hardening Self-Hosted Runners](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions#hardening-for-self-hosted-runners)  

---

### **Prerequisites**  
1. **Docker or Podman**  
   Ensure that either `docker` or `podman` is installed and configured on your system.  

---

### **Building the Runner Images**  

Use the script `docker.sh` or `podman.sh` to build OCI images for the runner.  

#### **Command Syntax**  
```
sudo ./scripts/docker.sh <os> <version> <setup_type>
```
```
sudo ./scripts/podman.sh <os> <version> <setup_type>
```
#### **Parameters**  
- **`-b <buildtool>`**: The tool to use for building images. Defaults to `podman` or `docker` based on availability. Specify explicitly if required.  
- **`[distro ...]`**: Specify the distribution to build images for (`ubuntu`, `almalinux`, or `opensuse`). If omitted, images for all supported distributions are built.  

---

### **Configuring Network and Firewall**  

To enable communication between GitHub and the self-hosted runner, you may need to adjust firewall settings:  
- Example for a service listening on port `5000`:  
  ```bash
  firewall-cmd --add-port=5000/tcp
  ```  
- If using multiple runners with unique ports, map each external port to port `443` within the OCI runtime. Update firewall rules accordingly.

---

### **Using the Self-Hosted Runner**  

#### **OCI Image Characteristics**  
The OCI image is ephemeral, meaning it requires configuration every time it is launched. To create an application-specific runner image:  
1. Use the base runner image built earlier.  
2. Pre-configure the runner with repository-specific details using a `Dockerfile`.  

---

### **Creating a Pre-Configured Runner Image**  

#### **Sample Dockerfile**  
```dockerfile
FROM localhost/runner:ubuntu

ARG REPO
ARG TOKEN

RUN /opt/runner/config.sh --url ${REPO} --token ${TOKEN}

CMD /opt/runner/run.sh
```  

#### **Build Commands**  
- **Docker**:  
  ```bash
  docker build --build-arg TOKEN=xxxxxx --build-arg REPO=yyyyy --squash -f Dockerfile.test --tag runner:test .
  ```  
- **Podman**:  
  ```bash
  podman build --build-arg TOKEN=xxxxxx --build-arg REPO=yyyyy --squash-all -f Dockerfile.test --tag runner:test .
  ```  

---

### **Running the Self-Hosted Runner**  

#### **Start Commands**  
- **Docker**:  
  ```bash
  docker run runner:test
  ```  
- **Podman**:  
  ```bash
  podman run runner:test
  ```  

#### **Sample Workflow for Testing**  
Create a workflow file (`.github/workflows/Makefile.yml`) in your repository:  
```yaml
name: Makefile CI

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]

jobs:
  build:
    runs-on: self-hosted
    steps:
    - uses: actions/checkout@v3

    - name: Install Dependencies
      run: sudo apt-get install -y golang-go

    - name: Build
      run: GOPATH=/home/ubuntu/go GOCACHE=/tmp/go make
```  

---

### **Example Run Output**  
When starting the runner:  
```bash
> podman run --rm -it runner:test

√ Connected to GitHub

Current runner version: '2.312.0'
2024-01-31 01:56:33Z: Listening for Jobs
2024-01-31 01:56:40Z: Running job: build
2024-01-31 01:57:39Z: Job build completed with result: Succeeded
```  

#### **GitHub Actions Workflow Status**  
Navigate to the GitHub Actions page for your repository to view workflow execution details.  
