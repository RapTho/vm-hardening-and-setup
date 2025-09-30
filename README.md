# VM Security Hardening and Deployment

This project provides tools for deploying and securing virtual machines in IBM Cloud:

- **Terraform** for automated VM deployment in IBM Cloud
- **Ansible** for hardening the security of RHEL-based VMs and setting up users and tools

## Prerequisites

### Required Tools

1. **IBM Cloud Account**

- Link to IBM Cloud: [https://cloud.ibm.com/](https://cloud.ibm.com/)

2. **Terraform**

- Follow the [official Terraform installation guide](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli#install-terraform)
- You'll need an [IBM Cloud API key](https://www.ibm.com/docs/en/masv-and-l/cd?topic=cli-creating-your-cloud-api-key)

3. **Ansible**
   More details can be found in the [ansible/README.md](./ansible/README.md).

```bash
python3 -m venv ansible-env
source ansible-env/bin/activate  # On Windows: ansible-env\Scripts\activate
pip install ansible-builder ansible-navigator
```

4. **Podman**

- Required for building the Ansible execution environment
- Follow the [official Podman installation guide](https://podman.io/getting-started/installation)

### How to use

1. Set up your IBM Cloud API key:

   ```bash
   export IC_API_KEY=your_api_key
   ```

2. Initialize Terraform:

   ```bash
   cd terraform
   terraform init
   ```

3. Customize your deployment:

   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your preferred settings
   ```

4. Deploy the VM:
   ```bash
   terraform apply
   ```

The deployment process will:

1. Check for and generate SSH keys if needed
2. Deploy the VM in IBM Cloud
3. Update the Ansible inventory with the new VM's IP address
4. Run the Ansible playbook to secure and set up the VM

## Ansible Roles

### secure-vm

The `secure-vm` role applies security hardening to a RHEL-based VM or its derivatives (CentOS, Rocky, AlmaLinux, Fedora).

Features:

- Firewall configuration with custom ports
- SELinux configuration
- SSH hardening:
  - Custom SSH port configuration
  - Disable password authentication (key-based only)
  - Disable root login

For more details, see the [secure-vm README](ansible/roles/secure-vm/README.md).

### setup-vm

The `setup-vm` role sets up users and installs tools on a VM.

Features:

- Creates a configurable number of users with sequential naming
- SSH key pair generation for each user
- Installs a configurable set of tools
- Optional sudo access for users

For more details, see the [setup-vm README](ansible/roles/setup-vm/README.md).

### SSH Keys for created users

When you run the playbook, the setup-vm role will create a `keys/` directory in your project root and populate it with the generated SSH keys

Find the keys at:

```bash
./keys/user1_id_rsa
./keys/user1_id_rsa.pub
./keys/user2_id_rsa
./keys/user2_id_rsa.pub
...
```

### Login using the generated keys

```bash
ssh -i keys/user1_id_rsa -p <ssh_port> user1@MyHostIP
```

## Configuration

### Customizing the secure-vm role

You can customize the secure-vm role by modifying the following files:

- `ansible/roles/secure-vm/defaults/main.yml`: Change default settings like SSH port and permitRootLogin
- `ansible/roles/secure-vm/vars/main.yml`: Add additional firewall ports

### Customizing the setup-vm role

You can customize the setup-vm role by modifying the following files:

- `ansible/roles/setup-vm/defaults/main.yml`: Change user settings and default tools
- `ansible/roles/setup-vm/vars/main.yml`: Add additional tools to install

### Customizing the Terraform deployment

You can customize the Terraform deployment by modifying the following files:

- `terraform/terraform.tfvars`: Set your preferred VM configuration
- `terraform/variables.tf`: Add or modify available variables
