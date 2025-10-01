# setup-vm

This role sets up users and installs tools on a VM.

## Requirements

- Target VM must be running RHEL or a derivative (CentOS, Rocky, AlmaLinux, Fedora)
- Ansible 2.9 or higher

## Role Variables

| Variable                  | Default                           | Description                                            |
| ------------------------- | --------------------------------- | ------------------------------------------------------ |
| users_count               | 1                                 | Number of users to create                              |
| users_base_name           | "user"                            | Base name for users (will be appended with a number)   |
| users_home_base           | "/home"                           | Base directory for user home directories               |
| users_create_sudo_access  | false                             | Whether to give users sudo access                      |
| default_tools_packages    | [tmux, git, vim, container-tools] | Default tools to install                               |
| additional_tools_packages | []                                | Additional tools to install (defined in vars/main.yml) |

Variables that can be defined in [vars/main.yml](vars/main.yml):

```yaml
# Define additional tools here
additional_tools_packages: []
# Example:
# additional_tools_packages:
#   - wget
#   - curl
#   - htop
```

## Features

### User Management

- Creates a configurable number of users with sequential naming (e.g., user1, user2, etc.)
- Optional sudo access for users (disabled by default)
- SSH key pair generation for each user

### Tools Installation

- Installs a configurable set of tools
- Default tools include tmux, git, vim, and container-tools
- Additional tools can be specified in vars/main.yml

## Example Playbook

```yaml
- hosts: servers
  vars:
    users_count: 3
    users_base_name: "developer"
    users_create_sudo_access: true
    additional_tools_packages:
      - wget
      - curl
  roles:
    - setup-vm
```
