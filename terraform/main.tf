locals {
  # If username is not provided, use the current user from environment variable
  user_env = getenv("USER")
  username_check = var.username != "" ? var.username : (local.user_env != "" ? local.user_env : null)
  
  # Validate that we have a username
  username = local.username_check != null ? local.username_check : tobool("ERROR: No username provided. Please set the 'username' variable or ensure USER environment variable is set.")
  
  # Read the SSH public keys
  ssh_public_key      = file(pathexpand("~/.ssh/id_rsa.pub"))
  ansible_public_key  = file(pathexpand("~/.ssh/id_rsa_ansible.pub"))
  
  # User data script for setting up users
  user_data = templatefile("${path.module}/user_data.tpl", {
    username           = local.username,
    ssh_public_key     = local.ssh_public_key,
    ansible_public_key = local.ansible_public_key,
  })
}

# Run the setup_keys.sh script to ensure SSH keys exist
resource "null_resource" "setup_keys" {
  provisioner "local-exec" {
    command = "bash ${path.module}/setup_keys.sh"
  }
}

# Create a resource group if it doesn't exist
resource "ibm_resource_group" "group" {
  name = var.resource_group
  depends_on = [null_resource.setup_keys]
}

# Create a VPC
resource "ibm_is_vpc" "vpc" {
  name           = var.vpc_name
  resource_group = ibm_resource_group.group.id
}

# Create a subnet
resource "ibm_is_subnet" "subnet" {
  name            = var.subnet_name
  vpc             = ibm_is_vpc.vpc.id
  zone            = var.zone
  ipv4_cidr_block = "10.240.0.0/24"
}

# Create a security group
resource "ibm_is_security_group" "security_group" {
  name           = var.security_group_name
  vpc            = ibm_is_vpc.vpc.id
  resource_group = ibm_resource_group.group.id
}

# Allow SSH traffic
resource "ibm_is_security_group_rule" "security_group_rule_ssh" {
  group     = ibm_is_security_group.security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = var.ssh_port
    port_max = var.ssh_port
  }
}

# Allow all outbound traffic
resource "ibm_is_security_group_rule" "security_group_rule_outbound" {
  group     = ibm_is_security_group.security_group.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

# Create an SSH key
resource "ibm_is_ssh_key" "ssh_key" {
  name           = "${var.vm_name}-key"
  public_key     = local.ssh_public_key
  resource_group = ibm_resource_group.group.id
}

# Get the image ID for RHEL
data "ibm_is_image" "image" {
  name = var.image_name
}

# Create a virtual server instance
resource "ibm_is_instance" "instance" {
  name           = var.vm_name
  vpc            = ibm_is_vpc.vpc.id
  zone           = var.zone
  profile        = var.vm_profile
  image          = data.ibm_is_image.image.id
  keys           = [ibm_is_ssh_key.ssh_key.id]
  resource_group = ibm_resource_group.group.id
  user_data      = local.user_data

  primary_network_interface {
    subnet          = ibm_is_subnet.subnet.id
    security_groups = [ibm_is_security_group.security_group.id]
  }
}

# Create a floating IP
resource "ibm_is_floating_ip" "floating_ip" {
  name           = "${var.vm_name}-ip"
  target         = ibm_is_instance.instance.primary_network_interface[0].id
  resource_group = ibm_resource_group.group.id
}

# Update the Ansible inventory with the new VM
resource "null_resource" "update_inventory" {
  depends_on = [ibm_is_floating_ip.floating_ip]

  provisioner "local-exec" {
    command = "bash ${path.module}/update_inventory.sh ${var.ssh_port}"
    environment = {
      TF_IP_ADDRESS = ibm_is_floating_ip.floating_ip.address
    }
  }
}

# Build the Ansible execution environment if needed
resource "null_resource" "build_ee" {
  depends_on = [null_resource.update_inventory]

  provisioner "local-exec" {
    command = "bash ${path.module}/build_ee.sh"
  }
}

# Run the Ansible playbook
resource "null_resource" "run_ansible" {
  depends_on = [null_resource.build_ee]

  provisioner "local-exec" {
    command = "cd ${path.module}/../ansible && ansible-navigator run playbook.yml -i inventory --eei localhost/ansible-execution-env:latest --pull-policy never || ansible-playbook -i inventory playbook.yml"
    working_dir = "${path.module}/../ansible"
  }
}