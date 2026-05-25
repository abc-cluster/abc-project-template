#!/usr/bin/env bash

set -e

VM_NAME="lxd-datasci"
VM_MEM="8G"
VM_DISK="40G"

# Install Multipass if not present
if ! command -v multipass >/dev/null 2>&1; then
  echo "Multipass not found. Please install it using 'brew install --cask multipass' and re-run this script."
  exit 1
fi

# Launch Ubuntu VM if not already running
if ! multipass list | grep -q "$VM_NAME"; then
  echo "Launching Ubuntu VM named $VM_NAME..."
  multipass launch --name $VM_NAME --mem $VM_MEM --disk $VM_DISK
else
  echo "VM $VM_NAME already exists."
fi

# Shell into VM and setup LXD and data science tools
multipass exec $VM_NAME -- bash -c '
  sudo apt-get update
  sudo snap install lxd
  sudo usermod -aG lxd ubuntu
  newgrp lxd <<EOF
  lxd init --auto
EOF
  # Install Python, Jupyter, R, etc. as needed
  sudo apt-get install -y python3 python3-pip r-base
  pip3 install --user jupyterlab pandas numpy matplotlib scikit-learn
'

echo "Setup complete. To use LXD:"
echo "multipass shell $VM_NAME"
echo "Inside the VM, you can use 'lxc launch ubuntu:22.04 my-ds-container' and 'lxc exec my-ds-container -- bash'"
