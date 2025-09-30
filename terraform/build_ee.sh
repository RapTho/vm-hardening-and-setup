#!/bin/bash

# This script checks if the Ansible execution environment exists and builds it if needed

# Check if podman is installed
if ! command -v podman &> /dev/null; then
    echo "Error: Podman is required but not installed. Please install it first."
    echo "See: https://podman.io/getting-started/installation"
    exit 1
fi

# Check if the execution environment image exists
if ! podman image exists localhost/ansible-execution-env:latest; then
    echo "Ansible execution environment not found. Building it now..."
    
    # Navigate to the ansible/ee directory
    cd "$(dirname "$0")/../ansible/ee" || exit 1
    
    # Create and activate Python virtual environment if it doesn't exist
    if [ ! -d "../ansible-env" ]; then
        echo "Creating Python virtual environment..."
        python3 -m venv ../ansible-env
    fi
    
    # Activate the virtual environment
    echo "Activating Python virtual environment..."
    source ../ansible-env/bin/activate
    
    # Check if ansible-builder is installed in the virtual environment
    if ! command -v ansible-builder &> /dev/null; then
        echo "Installing ansible-builder..."
        pip install ansible-builder
    fi
    
    # Create the build context if it doesn't exist
    if [ ! -d "context" ]; then
        echo "Creating build context..."
        ansible-builder create
    fi
    
    # Copy the roles to the context directory
    echo "Copying roles to context directory..."
    mkdir -p context/roles
    cp -r ../roles/* context/roles/
    
    # Build the execution environment
    echo "Building the execution environment..."
    ansible-builder build -v
    
    # Deactivate the virtual environment
    deactivate
    
    echo "Ansible execution environment built successfully."
else
    echo "Ansible execution environment already exists."
fi

exit 0