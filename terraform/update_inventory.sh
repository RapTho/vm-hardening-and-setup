#!/bin/bash

# Get the IP address from environment variable or Terraform output
if [ -n "$TF_IP_ADDRESS" ]; then
    IP_ADDRESS="$TF_IP_ADDRESS"
else
    IP_ADDRESS=$(terraform output instance_ip | tr -d '"')
fi

SSH_PORT=${1:-22}  # Use provided port or default to 22

# Validate IP address format
if [[ ! $IP_ADDRESS =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "Error: Invalid IP address format: $IP_ADDRESS"
    exit 1
fi

# Check if the IP already exists in the inventory
if grep -q "$IP_ADDRESS" ../ansible/inventory; then
    echo "IP address $IP_ADDRESS already exists in inventory"
    exit 0
fi

# Add the new VM to the inventory under the [workstation] section
sed -i "/\[workstation\]/a $IP_ADDRESS ansible_port=\"{{ ssh_port }}\" ansible_ssh_private_key_file=~/.ssh/id_rsa_ansible" ../ansible/inventory

echo "Updated ansible inventory with new VM: $IP_ADDRESS"

# Update the secure-vm role's defaults/main.yml to use the same SSH port
sed -i "s/^ssh_port:.*/ssh_port: $SSH_PORT/" ../ansible/roles/secure-vm/defaults/main.yml

echo "Updated secure-vm role with SSH port: $SSH_PORT"