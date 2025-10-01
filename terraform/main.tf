# Run the setup_keys.sh script to ensure SSH keys exist
resource "null_resource" "setup_keys" {
  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/setup_keys.sh"
  }
}

# Read SSH keys after ensuring they exist
data "local_file" "ssh_public_key" {
  depends_on = [null_resource.setup_keys]
  filename   = pathexpand("~/.ssh/id_rsa.pub")
}

data "local_file" "ansible_public_key" {
  depends_on = [null_resource.setup_keys]
  filename   = pathexpand("~/.ssh/id_rsa_ansible.pub")
}

locals {
  # Use the SSH public keys from data sources
  ssh_public_key      = data.local_file.ssh_public_key.content
  ansible_public_key  = data.local_file.ansible_public_key.content
  
  # User data script for setting up users
  user_data = templatefile("${path.module}/scripts/user_data.tpl", {
    username           = var.username,
    ssh_public_key     = local.ssh_public_key,
    ansible_public_key = local.ansible_public_key,
  })
}

# Create the resource group
resource "ibm_resource_group" "group" {
  name = var.resource_group
}

# Create VPC
resource "ibm_is_vpc" "vpc" {
  name           = var.vpc_name
  resource_group = ibm_resource_group.group.id
  depends_on     = [null_resource.setup_keys]
}

# Create VPC address prefix
resource "ibm_is_vpc_address_prefix" "vpc_address_prefix" {
  name = "${var.vpc_name}-prefix"
  vpc  = ibm_is_vpc.vpc.id
  zone = var.zone
  cidr = "10.0.0.0/16"
}

# Create subnet
resource "ibm_is_subnet" "subnet" {
  name            = var.subnet_name
  vpc             = ibm_is_vpc.vpc.id
  zone            = var.zone
  ipv4_cidr_block = "10.0.0.0/24"
  depends_on      = [ibm_is_vpc_address_prefix.vpc_address_prefix]
}

# Create security group
resource "ibm_is_security_group" "security_group" {
  name           = var.security_group_name
  vpc            = ibm_is_vpc.vpc.id
  resource_group = ibm_resource_group.group.id
}

# Add default SSH rule (port 22) to security group
resource "ibm_is_security_group_rule" "security_group_rule_ssh_default" {
  group     = ibm_is_security_group.security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = var.default_ssh_port
    port_max = var.default_ssh_port
  }
}

# Add custom SSH rule to security group
resource "ibm_is_security_group_rule" "security_group_rule_ssh_custom" {
  group     = ibm_is_security_group.security_group.id
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp {
    port_min = var.custom_ssh_port
    port_max = var.custom_ssh_port
  }
}

# Add outbound rule to security group
resource "ibm_is_security_group_rule" "security_group_rule_outbound" {
  group     = ibm_is_security_group.security_group.id
  direction = "outbound"
  remote    = "0.0.0.0/0"
}

# Create SSH key
resource "ibm_is_ssh_key" "ssh_key" {
  name           = "${var.vm_name}-key"
  public_key     = local.ssh_public_key
  resource_group = ibm_resource_group.group.id
}

# Get the image ID for RHEL
data "ibm_is_image" "image" {
  name = var.image_name
}

# Create instance
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

# Create floating IP
resource "ibm_is_floating_ip" "floating_ip" {
  name           = "${var.vm_name}-ip"
  target         = ibm_is_instance.instance.primary_network_interface[0].id
  resource_group = ibm_resource_group.group.id
}

# Store the floating IP address for output
locals {
  floating_ip_address = ibm_is_floating_ip.floating_ip.address
}

# Update the Ansible inventory with the new VM
resource "null_resource" "update_inventory" {
  triggers = {
    floating_ip = local.floating_ip_address
  }

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/update_inventory.sh"
    environment = {
      TF_IP_ADDRESS = local.floating_ip_address
      TF_DEFAULT_SSH_PORT = var.default_ssh_port
      TF_CUSTOM_SSH_PORT = var.custom_ssh_port
    }
  }
}

# Build the Ansible execution environment if needed
resource "null_resource" "build_ee" {
  depends_on = [null_resource.update_inventory]

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/build_ee.sh"
  }
}

# Run the Ansible playbook
resource "null_resource" "run_ansible" {
  depends_on = [null_resource.build_ee, null_resource.update_inventory]

  provisioner "local-exec" {
    command = "bash ${path.module}/scripts/run_ansible.sh"
    interpreter = ["/bin/bash", "-c"]
    environment = {
      TF_IP_ADDRESS = local.floating_ip_address
      SSH_PORT = var.default_ssh_port
    }
  }
}