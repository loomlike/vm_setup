# Setup Multiple Virtual Machines with Multiple JupyterHub User Accounts

This repository shows how to setup multiple Data Science Virtual Machines (DSVMs) with multiple user accounts.
More specifically, it deploys Azure VMSS (Virtual Machine Scale Set) and invokes the post-deployment-script on each VM instance
to:
1. Clone an example project repository,
1. Setup conda environment for the project, and
1. Create multiple JupyterHub users (Each user can access JupyterHub by opening `https://vm-ip-address:8000`)

This approach best fits when you give a hands-on / lab session so that you need to setup multiple VMs with environment setup
