# VM Security Hardening and Setup

This project provides Ansible roles for hardening the security of RHEL-based VMs and setting up users and tools.

## Roles

### secure-vm

The `secure-vm` role applies security hardening to a RHEL-based VM or its derivatives (CentOS, Rocky, AlmaLinux, Fedora).

Features:

- OS detection for RHEL and derivatives
- Custom SSH port configuration
- Firewall configuration with configurable ports
- SELinux configuration
- SSH hardening:
  - Disable password authentication (key-based only)
  - Disable root login (configurable)

For more details, see the [secure-vm README](roles/secure-vm/README.md).

### setup-vm

The `setup-vm` role sets up users and installs tools on a VM.

Features:

- Creates a configurable number of users with sequential naming
- Each user gets their own home directory
- Optional sudo access for users
- SSH key pair generation for each user
- Installs a configurable set of tools

For more details, see the [setup-vm README](roles/setup-vm/README.md).

## Getting started with Execution Environment

This project uses an Ansible Execution Environment (EE) to package the roles and their dependencies into a container image, providing a consistent environment for running the playbooks.

Checkout the [ee/README.md](./ee/README.md) for build instructions to build your execution environment container image.

### Preparing your target machine(s)

1. Create an ansible user with sudo privileges on your managed host:

```bash
sudo useradd ansible
sudo passwd ansible
sudo echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible
```

2. Create SSH keys and copy the public key to all remote hosts you wish to manage:

```bash
ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa_ansible
ssh-copy-id -i ~/.ssh/id_rsa_ansible.pub ansible@YOUR_HOST_IP
```

3. Update the inventory file with your VM's IP address or hostname:

```ini
[workstation]
YOUR_HOST_IP ansible_port="{{ ssh_port }}" ansible_ssh_private_key_file=~/.ssh/id_rsa_ansible
```

### Running Playbooks with the Execution Environment

Run the playbook using `ansible-navigator` with the execution environment:

```bash
ansible-navigator run playbook.yml -i inventory --eei localhost/ansible-execution-env:latest --pull-policy never
```

### SSH Keys for created users

When you run the playbook, the setup-vm role will:

1. Create a `keys/` directory in your project root
2. Generate SSH key pairs for each user in this directory
3. Configure the users on the target VM with these keys

The keys are stored on your local machine (in the project directory), not in the execution environment.
After running the playbook, you'll find the keys at:

```bash
./keys/user1_id_rsa
./keys/user1_id_rsa.pub
./keys/user2_id_rsa
./keys/user2_id_rsa.pub
...
```

## Configuration

### Customizing the secure-vm role

You can customize the secure-vm role by modifying the following files:

- `roles/secure-vm/defaults/main.yml`: Change default settings like SSH port and default firewall ports
- `roles/secure-vm/vars/main.yml`: Add additional firewall ports

### Customizing the setup-vm role

You can customize the setup-vm role by modifying the following files:

- `roles/setup-vm/defaults/main.yml`: Change user settings and default tools
- `roles/setup-vm/vars/main.yml`: Add additional tools to install

For more detailed information about the execution environment, see the [Execution Environment README](ee/README.md).
