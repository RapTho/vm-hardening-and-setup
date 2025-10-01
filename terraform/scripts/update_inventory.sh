#!/bin/bash

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ANSIBLE_DIR="$SCRIPT_DIR/../../ansible"
INVENTORY_FILE="${ANSIBLE_DIR}/inventory"
ROLE_DEFAULTS="${ANSIBLE_DIR}/roles/secure-vm/defaults/main.yml"

# Get the IP address from environment variable or Terraform output
if [ -n "$TF_IP_ADDRESS" ]; then
    IP_ADDRESS="$TF_IP_ADDRESS"
else
    IP_ADDRESS=$(terraform output instance_ip | tr -d '"')
fi

# Get the default SSH port from environment variable
if [ -n "$TF_DEFAULT_SSH_PORT" ]; then
    DEFAULT_SSH_PORT="$TF_DEFAULT_SSH_PORT"
else
    echo "Error: TF_DEFAULT_SSH_PORT environment variable is not set"
    exit 1
fi

# Get the custom SSH port from environment variable
if [ -n "$TF_CUSTOM_SSH_PORT" ]; then
    CUSTOM_SSH_PORT="$TF_CUSTOM_SSH_PORT"
else
    echo "Error: TF_CUSTOM_SSH_PORT environment variable is not set"
    exit 1
fi

# Validate IP address format
if [[ ! $IP_ADDRESS =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Invalid IP address format: $IP_ADDRESS"
    exit 1
fi

# Check if the inventory file exists
if [ ! -f "$INVENTORY_FILE" ]; then
    echo "Error: Ansible inventory file not found at $INVENTORY_FILE"
    exit 1
fi

# Check if the IP already exists in the inventory
if grep -q "$IP_ADDRESS" "$INVENTORY_FILE"; then
    echo "IP address $IP_ADDRESS already exists in inventory, updating it"
    sed -i "s/^[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}.*/$IP_ADDRESS ansible_port=$DEFAULT_SSH_PORT ansible_ssh_private_key_file=~\/.ssh\/id_rsa_ansible/" "$INVENTORY_FILE"
else
    # Add the new VM to the inventory under the [workstation] section
    sed -i "/\[workstation\]/a $IP_ADDRESS ansible_port=$DEFAULT_SSH_PORT ansible_ssh_private_key_file=~/.ssh/id_rsa_ansible" "$INVENTORY_FILE"
fi

echo "Updated ansible inventory with new VM: $IP_ADDRESS using default SSH port: $DEFAULT_SSH_PORT"

# Update the secure-vm role's defaults/main.yml to use the custom SSH port
if [ -f "$ROLE_DEFAULTS" ]; then
    sed -i "s/^ssh_port:.*/ssh_port: $CUSTOM_SSH_PORT/" "$ROLE_DEFAULTS"
    echo "Updated secure-vm role with custom SSH port: $CUSTOM_SSH_PORT"
else
    echo "Warning: Could not find secure-vm role defaults at $ROLE_DEFAULTS"
fi

echo "Updated secure-vm role with custom SSH port: $CUSTOM_SSH_PORT"