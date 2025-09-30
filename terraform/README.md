# IBM Cloud VM Deployment with Terraform

This Terraform configuration deploys a virtual machine in IBM Cloud with the following features:

- Creates a custom user based on the current user or a specified username
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
3. Ensure you have Podman installed for building the Ansible execution environment

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
2. Build the Ansible execution environment if it doesn't exist
3. Deploy the VM in IBM Cloud
4. Update the Ansible inventory with the new VM
5. Run the Ansible playbook to secure and set up the VM

## Variables

| Name                | Description                 | Default                        |
| ------------------- | --------------------------- | ------------------------------ |
| resource_group      | Name of the resource group  | default                        |
| region              | IBM Cloud region            | us-south                       |
| zone                | Availability zone           | us-south-1                     |
| vpc_name            | Name of the VPC             | vm-vpc                         |
| subnet_name         | Name of the subnet          | vm-subnet                      |
| security_group_name | Name of the security group  | vm-security-group              |
| vm_name             | Name of the VM              | vm-instance                    |
| vm_profile          | VM profile (CPU and memory) | cx2-2x4                        |
| image_name          | OS image name               | ibm-redhat-8-6-minimal-amd64-3 |
| ssh_port            | SSH port                    | 32122                          |
| username            | Username for default user   | Current system user            |
