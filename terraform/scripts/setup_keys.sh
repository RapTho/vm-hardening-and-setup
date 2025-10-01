#!/bin/bash

# Check if default SSH key exists
if [ ! -f ~/.ssh/id_rsa ] || [ ! -f ~/.ssh/id_rsa.pub ]; then
    echo "Generating default SSH key pair..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N ""
else
    echo "Default SSH key pair already exists."
fi

# Check if ansible SSH key exists
if [ ! -f ~/.ssh/id_rsa_ansible ] || [ ! -f ~/.ssh/id_rsa_ansible.pub ]; then
    echo "Generating ansible SSH key pair..."
    ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa_ansible -N ""
else
    echo "Ansible SSH key pair already exists."
fi

echo "SSH keys are ready to use."