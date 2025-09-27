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

## Prerequisites

As Ansible is not included in the RHEL8 repositories, you need to add a new repo

```
sudo subscription-manager repos --enable ansible-2-for-rhel-8-x86_64-rpms
```

Install Ansible on your Red Hat Enterprise Linux host.

```
sudo yum -y install ansible
```

Create an ansible user with sudo privileges on your managed host, which doesn't require a password to elevate privileges

```
sudo useradd ansible
sudo passwd ansible
sudo echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible
```

Create ssh keys and copy the public key to all remote hosts you wish to manage. Replace **MYHOST** with your remote host e.g. 192.168.1.2

```
ssh-keygen -q -t rsa -N '' -f ~/.ssh/id_rsa_ansible
ssh-copy-id -i ~/.ssh/id_rsa_ansible.pub ansible@MYHOST
```

## Clone the repository

```
raphael@desktop:~$ git clone https://github.com/RapTho/vm-security-hardening.git
raphael@desktop:~$ cd vm-security-hardening
```

## Add your ansible managed vm

In the [inventory](inventory) file, replace the example IP address with your vm's IP or FQDN.

Do **NOT remove** the ansible_port or ansible_ssh_private_key_file.

```
[workstation]
192.168.122.136 ansible_port="{{ ssh_port }}" ansible_ssh_private_key_file=~/.ssh/id_rsa_ansible
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

## Run the Ansible playbook

The remote host will be **reset** to its previous state. All workshop users and their home directories will be deleted!

```
raphael@desktop:~$ ansible-playbook playbook.yml
```

The VM is now ready with security hardening applied and users/tools set up.
