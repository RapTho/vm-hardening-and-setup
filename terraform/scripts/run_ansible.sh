#!/bin/bash

# This script sets up and runs the Ansible playbook
# It's called from Terraform's null_resource.run_ansible

# Get script directory and navigate to ansible directory
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR/../../ansible"

# Ensure the inventory file has the correct IP address
echo "Verifying inventory file has the correct IP address..."
if ! grep -q "$TF_IP_ADDRESS" inventory; then
  echo "Warning: IP address $TF_IP_ADDRESS not found in inventory, running update_inventory.sh again"
  bash "$SCRIPT_DIR/update_inventory.sh" ${SSH_PORT}
fi

# Setup Python virtual environment
if [ ! -d "ansible-env" ]; then
  echo "Creating Python virtual environment..."
  python3 -m venv ansible-env
fi

echo "Activating Python virtual environment..."
source ansible-env/bin/activate

echo "Installing Ansible dependencies..."
pip install --upgrade pip
pip install ansible-navigator

echo "Running Ansible playbook..."
ansible-navigator run playbook.yml -i inventory --eei localhost/ansible-execution-env:latest --pull-policy never

deactivate
