# Packer Lab

Packer images 

## Devcontainer

In reference to Ubuntu2404: 

This currently does not work. Even when setting network_mode to host, the container is not given an IP on the corrent subnet when executed from my macbook.

When running outside of the devcontainer, on my macbook, an IP address in the correct subnet is assigned, but the process gets stuck seeming when attempting to read in the cloud config file. The automated processes are stopped and manual intervention is prompted as if setting up a new machine manually. 

If I spin up a VM (ubuntu) on Proxmox and run the packer build command, the process completes successfully, resulting in a Proxmox VM template. 