# secure-vm

This role applies security hardening to a RHEL-based VM or its derivatives (CentOS, Rocky, AlmaLinux, Fedora).

## Requirements

- Target VM must be running RHEL or a derivative (CentOS, Rocky, AlmaLinux, Fedora)
- Ansible 2.9 or higher

## Role Variables

Settable variables for this role that are in [defaults/main.yml](defaults/main.yml):

```yaml
# Whether to allow root login via SSH
permitRootLogin: false

# Custom SSH port to use
ssh_port: 32122

# Default firewall allowed ports
default_firewall_allowed_ports:
  - "{{ ssh_port }}/tcp"

# This will be merged with user-defined ports in vars/main.yml
firewall_allowed_ports: "{{ default_firewall_allowed_ports + additional_firewall_allowed_ports | default([]) }}"
```

Variables that can be defined in [vars/main.yml](vars/main.yml):

```yaml
# Define additional ports here
additional_firewall_allowed_ports: []
# Example:
# additional_firewall_allowed_ports:
#   - "443/tcp"
#   - "80/tcp"
```

## Features

- OS detection for RHEL and derivatives
- Firewall configuration with configurable ports
- SELinux configuration
- SSH hardening:
  - Custom SSH port configuration
  - Disable password authentication (key-based only)
  - Disable root login

## Example Playbook

```yaml
- hosts: workstation
  roles:
    - secure-vm
```
