# Get Ready to Work with Linux (Virtual) Machines

Setup a remote VM and *conda* for data science / python dev.

## Table of Contents

1. Configure **ssh**
2. Beautify **bash** 
3. Setup **git**
4. Config VScode
5. Jupyter
6. Extras
    * Setup 100 VMs with a single script (feat. Azure VMSS)

## 1. Configure **ssh**

```
# ~/.ssh/config
Host {my_vm_name}
    HostName     {my_vm_address}
    User         {my_vm_account}
    LocalForward {port_to_tunnel} localhost:{port_to_tunnel}
    ForwardAgent yes
```

## 2. Beautify **bash**



## 3. Setup **git**

```
git config --global user.name {my_name}
git config --global user.email {my_github_email}
git config --global core.editor "vi"
```

## 4. VScode for **python**

## 5. Jupyter
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


## 6. Extras

### 1) Setup 100 VMs with a single script (feat. Azure VMSS)

This section shows how to setup multiple Azure Data Science Virtual Machines (DSVMs) with multiple user accounts.
More specifically, it deploys Azure VMSS (Virtual Machine Scale Set) and invokes the post-deployment-script on each VM instance
to:
1. Clone an example project repository,
1. Setup conda environment for the project, and
1. Create multiple JupyterHub users (Each user can access JupyterHub by opening `https://vm-ip-address:8000`)
