#!/bin/bash
# Multipass setup script for {{ project_name }}

set -e

# Check if Multipass is installed
if ! command -v multipass &> /dev/null; then
    echo "Multipass not found. Please install it following the instructions at:"
    echo "https://multipass.run/install"
    exit 1
fi

VM_NAME="{{ project_name|lower|replace(' ', '-') }}"
CLOUD_INIT="$(dirname "$0")/cloud-init/{{ multipass_profile }}.yaml"

# Check if VM already exists
if multipass info "$VM_NAME" &> /dev/null; then
    echo "VM '$VM_NAME' already exists"
else
    echo "Creating new VM '$VM_NAME'..."
    multipass launch --name "$VM_NAME" \
                    --memory {{ multipass_memory }} \
                    --cpus {{ multipass_cpus }} \
                    --disk {{ multipass_disk }} \
                    --cloud-init "$CLOUD_INIT" \
                    22.04
fi

echo "VM setup complete. Access with: multipass shell $VM_NAME"
echo "Or mount your project files with: multipass mount . $VM_NAME:/home/datascientist/{{ project_name|lower|replace(' ', '-') }}"
