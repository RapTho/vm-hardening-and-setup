#!/bin/bash

# Update system
dnf update -y
dnf upgrade -y

# Create user if it doesn't exist
if ! id "${username}" &>/dev/null; then
    useradd -m -s /bin/bash "${username}"
    # Add user to wheel group for sudo access (requires password)
    usermod -aG wheel "${username}"
fi

# Set up SSH for the user
mkdir -p /home/${username}/.ssh
echo "${ssh_public_key}" > /home/${username}/.ssh/authorized_keys
chmod 700 /home/${username}/.ssh
chmod 600 /home/${username}/.ssh/authorized_keys
chown -R ${username}:${username} /home/${username}/.ssh

# Create ansible user
useradd -m -s /bin/bash ansible
# Give ansible user passwordless sudo
echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible
chmod 0440 /etc/sudoers.d/ansible

# Set up SSH for ansible user
mkdir -p /home/ansible/.ssh
echo "${ansible_public_key}" > /home/ansible/.ssh/authorized_keys
chmod 700 /home/ansible/.ssh
chmod 600 /home/ansible/.ssh/authorized_keys
chown -R ansible:ansible /home/ansible/.ssh