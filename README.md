# VM security hardening and setup

This project provides Ansible roles for hardening the security of RHEL-based VMs and setting up users and tools.

## Roles

### secure-vm

The `secure-vm` role applies security hardening to a RHEL-based VM or its derivatives (CentOS, Rocky, AlmaLinux, Fedora).

Features:

- Firewall configuration with custom ports
- SELinux configuration
- SSH hardening:
  - Custom SSH port configuration
  - Disable password authentication (key-based only)
  - Disable root login

For more details, see the [secure-vm README](roles/secure-vm/README.md).

### setup-vm

The `setup-vm` role sets up users and installs tools on a VM.

Features:

- Creates a configurable number of users with sequential naming
- SSH key pair generation for each user
- Installs a configurable set of tools
- Optional sudo access for users

For more details, see the [setup-vm README](roles/setup-vm/README.md).

## Getting started with Execution Environment

This project uses an Ansible Execution Environment (EE) to package the roles and their dependencies into a container image, providing a consistent environment for running the playbooks.

Checkout the [ee/README.md](./ee/README.md) for build instructions to build your execution environment container image.

### Installing the execution tool

Install `ansible-navigator` in a virtual environment (recommended) using pip

```bash
python3 -m venv ansible-env
source ansible-env/bin/activate  # On Windows: ansible-env\Scripts\activate
pip install ansible-navigator
```

### Preparing your target(s)

1. Create an ansible user with sudo privileges on your targets:

```bash
sudo useradd ansible
sudo passwd ansible
sudo echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible
```

2. Create SSH keys and copy the public key to all targets you wish to manage:

```bash
ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa_ansible
ssh-copy-id -i ~/.ssh/id_rsa_ansible.pub ansible@YOUR_HOST_IP
```

3. Update the [inventory file](./inventory) with your target's IP address or hostname:

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

Find the keys at:

```bash
./keys/user1_id_rsa
./keys/user1_id_rsa.pub
./keys/user2_id_rsa
./keys/user2_id_rsa.pub
...
```

### Login using the generated keys

```bash
ssh -i keys/user1_id_rsa -p <ssh_port> user1@MyHostIP
```

## Configuration

### Customizing the secure-vm role

You can customize the secure-vm role by modifying the following files:

- `roles/secure-vm/defaults/main.yml`: Change default settings like SSH port and permitRootLogin
- `roles/secure-vm/vars/main.yml`: Add additional firewall ports

### Customizing the setup-vm role

You can customize the setup-vm role by modifying the following files:

- `roles/setup-vm/defaults/main.yml`: Change user settings and default tools
- `roles/setup-vm/vars/main.yml`: Add additional tools to install
