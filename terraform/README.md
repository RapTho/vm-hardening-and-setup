# IBM Cloud VM Deployment with Terraform

This Terraform configuration deploys a virtual machine in IBM Cloud with the following features:

- Creates a custom user based on the specified username (default: adm1n)
- Sets up the user with sudo privileges
- Creates an ansible user with passwordless sudo
- Sets up SSH keys for both users
- Automatically runs the Ansible playbook to secure and set up the VM

## Prerequisites

1. Install Terraform
2. Set up IBM Cloud API key as an environment variable:

   ```
   export IC_API_KEY=your_api_key
   ```

3. Make sure to specify your IBM Cloud Account ID in the terraform.tfvars file
   .
4. Ensure you have Podman installed for building the Ansible execution environment

## Usage

1. Initialize Terraform:

   ```
   terraform init
   ```

2. Customize your deployment:

   ```
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars with your preferred settings
   ```

3. Apply the configuration:
   ```
   terraform apply
   ```

The Terraform configuration will:

1. Check for and generate SSH keys if needed
2. Check for existing resources in IBM Cloud and automatically reuse them if available
3. Create any resources that don't already exist
4. Build the Ansible execution environment if it doesn't exist
5. Deploy the VM in IBM Cloud (or use existing VM if available)
6. Update the Ansible inventory with the VM's IP address
7. Run the Ansible playbook to secure and set up the VM

## Variables

| Name                | Description                 | Default                         |
| ------------------- | --------------------------- | ------------------------------- |
| account_id          | IBM Cloud Account ID        | (required, no default)          |
| resource_group      | Name of the resource group  | default                         |
| region              | IBM Cloud region            | eu-de                           |
| zone                | Availability zone           | eu-de-1                         |
| vpc_name            | Name of the VPC             | vm-vpc                          |
| subnet_name         | Name of the subnet          | vm-subnet                       |
| security_group_name | Name of the security group  | vm-security-group               |
| vm_name             | Name of the VM              | vm-instance                     |
| vm_profile          | VM profile (CPU and memory) | cx2d-4x8                        |
| image_name          | OS image name               | ibm-redhat-9-4-minimal-amd64-10 |
| ssh_port            | SSH port                    | 32122                           |
| username            | Username for default user   | adm1n                           |
