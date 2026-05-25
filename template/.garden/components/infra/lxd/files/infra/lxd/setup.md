# LXD Data Science Environment on macOS

This template lets you run a full-featured Linux data science environment on macOS, leveraging Multipass and LXD.

## Quick Start

1. **Install Multipass if needed**  
   ```bash
   brew install --cask multipass
   ```

2. **Launch and set up the LXD VM**  
   ```bash
   just setup-lxd-macos
   ```

3. **Shell into the VM**  
   ```bash
   multipass shell lxd-datasci
   ```

4. **Launch a data science LXD container**  
   ```bash
   lxc launch ubuntu:22.04 my-ds-container
   lxc exec my-ds-container -- bash
   # Install your tools inside the container as needed
   ```

## Notes

- Jupyter, Python, and R are installed in the VM. You can also install them inside LXD containers for true isolation.
- You can forward ports (e.g., for JupyterLab) using Multipass if needed.
- For GPU support, advanced networking, or persistent volumes, see the [Multipass](https://multipass.run/docs) and [LXD](https://linuxcontainers.org/lxd/) docs.

