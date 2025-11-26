# Get Ready to Work on Linux (Virtual) Machines

Setup a linux machine for data science work & python dev.

## Table of Contents

1. Configure **ssh**
2. Beautify **bash**
3. WSL
4. Setup **git**
5. Config VScode
6. Jupyter
7. Extras
    * Setup 100 VMs with a single script via Azure VMSS
    * WSL (windows subsystem for linux)

## 1. Configure **ssh**
```
# ~/.ssh/config
Host {vm_name}
    HostName     {vm_host_name_or_ip_address}
    Port         {vm_ssh_port}
    User         {vm_account}
    LocalForward {port_to_tunnel} localhost:{port_to_tunnel}
    ForwardAgent yes
```

### Change ssh port
```bash
# 1. Set `Port`:
sudo vi /etc/ssh/sshd_config

# 2. Restart sshd service:
sudo systemctl restart sshd

# 3. Confirm change
sudo netstat -tulpn | grep ssh

# 4. (Optional) Add a rule to nsg (if use Azure VM)

# 5. Connect by specifying the port
ssh -p PORT_NUMBER USER_NAME@IP_ADDRESS
```

### Access VMs with VNet via Azure VPN

Follow [Azure work-remotely-support doc](https://learn.microsoft.com/en-us/azure/vpn-gateway/work-remotely-support)

1. Create a VNet, subnet, and [vnet gateway](https://learn.microsoft.com/en-us/azure/vpn-gateway/tutorial-create-gateway-portal)
2. [Configure point-to-site VPN](https://learn.microsoft.com/en-us/azure/vpn-gateway/openvpn-azure-ad-tenant) on the gateway
3. Download and distribute the VPN client configuration
4. Distribute the certificates
5. Connect to Azure VPN

## Alternative 1. Setup GCM (Git Credential Manager)
```
git config --global credential.helper "/mnt/c/Program\ Files/Git/mingw64/bin/git-credential-manager.exe"

```
git config --global credential.https://dev.azure.com.useHttpPath true
```

## 2. Beautify **bash**
Copy .bashrc file to the home directory:
`cp .bashrc ~/.bashrc`
> you may need to add the following line to `~/.bash_profile`:
> ```
> ... 
> source ~/.bashrc
> ```

This will change the bash prompt to be:
`current_conda_env:current_git_branch(if dir is a git repo) trimmed_working_dir $ `

E.g.,
`base:master ~/.../git/vm_setup $`

The branch status will be shown as colors: clean - white, dirty - red, staged - yellow, committed - green:

![](./prompt.png)

## 3. WSL

Enable integration with Windows browsers (so that one can use interactive az logins):
`sudo apt install xdg-utils wslu` 

## 4. Setup **git**

```
git config --global user.name {my_name}
git config --global user.email {my_github_email}
git config --global core.editor "vi"
```

## 5. VScode for **python**

## 6. Jupyter
```
jupyter notebook --generate-config

# then edit the generated `jupyter_notebook_config.py` to be:
# c.NotebookApp.open_browser = False
```
> Note, Azure DSVM's JupyterHub config path is `/etc/jupyterhub/jupyterhub_config.py`

Enable widgets:
```
jupyter nbextension enable --py widgetsnbextension
```

Change Jupyter Theme:
```
pip install jupyterthemes
jt -t grade3 -fs 95 -tfs 11 -nfs 115 -cellw 90% -T -N
```

## 7. NVIDIA driver update

1. Remove any existing Nvidia packages:

    `sudo apt-get remove --purge nvidia-*`

1. Auto-remove unnecessary packages:

    `sudo apt autoremove`

1. Install the Nvidia driver:
    `sudo apt-get install ubuntu-drivers-common`
    
    `sudo ubuntu-drivers autoinstall`

1. Reboot your system:

    `sudo reboot`

## . Extras

### Setup 100 VMs with a single script via Azure VMSS

This section shows how to setup multiple Azure Data Science Virtual Machines (DSVMs) with multiple user accounts.
More specifically, it deploys Azure VMSS (Virtual Machine Scale Set) and invokes the post-deployment-script on each VM instance
to:
1. Clone an example project repository,
1. Setup conda environment for the project, and
1. Create multiple JupyterHub users (Each user can access JupyterHub by opening `https://vm-ip-address:8000`)

### WSL (windows subsystem for linux)

- [Windows Terminal](https://github.com/microsoft/terminal) config
    ```
    "defaults":
        {
            "cursorColor" : "#ffdb59",
            "cursorHeight" : 100,
            "cursorShape" : "vintage",
            "fontFace" : "Fira Code",
            "fontSize" : 10,
            "colorScheme": "One Half Dark"
        },
    ```
- Transparent terminal by using AutoHotKey ([related thread](https://github.com/microsoft/terminal/issues/1753))
    ```
    #^Esc::
     WinGet, TransLevel, Transparent, A
     If (TransLevel = OFF) {
       WinSet, Transparent, 200, A
     } Else {
       WinSet, Transparent, OFF, A
     }
    return
    ```

