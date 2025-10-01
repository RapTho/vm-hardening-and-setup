# Ansible Execution Environment

This directory contains the configuration for building an Ansible Execution Environment (EE) based on Red Hat UBI 9.

## Prerequisites

- [Podman](https://podman.io/) installed on your system
- Python 3.9 or newer

## Installing build tools

Install `ansible-builder` in a virtual environment (recommended) using pip

```bash
python3 -m venv ansible-env
source ansible-env/bin/activate  # On Windows: ansible-env\Scripts\activate
pip install ansible-builder
```

## Building the Execution Environment

The process involves two main steps:

1. **Create the build context**: This generates the necessary files for building the container image.
2. **Build the container image**: This builds the actual execution environment image.

### Step 1: Create the build context

From **this directory** (`ee/`), run:

```bash
ansible-builder create
```

This will create a `context/` directory containing all the files needed to build the Execution Environment.

### Step 2: Build the container image

Copy the custom roles to the context folder:

```bash
cp -r ../roles context/roles
```

Build the container image:

```bash
ansible-builder build -v
```

## Using the Execution Environment

Check the [chapter in the parent's README.md](../README.md#running-playbooks-with-the-execution-environment) to learn how to use the execution environment.
