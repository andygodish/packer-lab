packer {
  required_plugins {
    proxmox = {
      version = ">=1.1.3"
      source  = "github.com/hashicorp/proxmox"
    }
  }
}

# Variables
variable "proxmox_url" {
  type = string
}

variable "proxmox_node" {
  type = string
}

variable "proxmox_token_id" {
  type = string
}

variable "proxmox_token_secret" {
  type = string
  sensitive = true
}

variable "template_description" {
  type    = string
  default = "Ubuntu 24.04 Template"
}

variable "template_name" {
  type    = string
  default = "Ubuntu-24.04-Template"
}

# Source block for Ubuntu 24.04
source "proxmox-iso" "autogenerated_1" {
  proxmox_url              = var.proxmox_url
  username                 = var.proxmox_token_id     # Format: "root@pam!tokenname"
  token                    = var.proxmox_token_secret # The actual token
  node                     = var.proxmox_node
  insecure_skip_tls_verify = true

  template_description = "${var.template_description}"
  template_name        = "${var.template_name}"

  # VM Configuration
  vm_name                 = "ubuntu-2404-template"
  template_description    = "Ubuntu 24.04 Cloud Image Template"
  vm_id                   = "1000"
  memory                  = "2048"
  cores                   = "2"
  sockets                 = "1"
  os                      = "l26"
  qemu_agent             = true
  scsi_controller        = "virtio-scsi-single"

  # ISO Configuration
  boot_iso {
    iso_file = "pve-backups:iso/ubuntu-24.04.1-live-server-amd64.iso"
    unmount = true
  }

  # Network Configuration
  network_adapters {
    bridge = "vmbr0"
    model  = "virtio"
    mac_address = "repeatable"
    mtu = 1
  }

  # Disk Configuration
  disks {
    disk_size         = "20G"
    storage_pool      = "local"
    type              = "scsi"
    format           = "raw"
  }

  # Cloud-Init Support
  cloud_init              = true
  cloud_init_storage_pool = "local-lvm"

  # HTTP Server for autoinstall
  http_directory = "ubuntu2404/http"
  boot_wait = "10s"
  boot_command = ["c<wait>linux /casper/vmlinuz --- autoinstall ip=dhcp ds='nocloud-net;s=http://{{ .HTTPIP }}:{{ .HTTPPort }}'<enter><wait5s>initrd /casper/initrd <enter><wait5s>boot <enter><wait5s>"]

  # SSH Settings
  ssh_username = "ubuntu"
  ssh_password = "ubuntu"
  ssh_timeout  = "20m"
}

# Build Configuration
build {
  sources = ["source.proxmox-iso.autogenerated_1"]

  # Post-Processors
  provisioner "shell" {
    inline = [
      "while [ ! -f /var/lib/cloud/instance/boot-finished ]; do echo 'Waiting for cloud-init...'; sleep 1; done",
      "sudo apt-get update",
      "sudo apt-get upgrade -y",
      "sudo apt-get install -y qemu-guest-agent",
      "sudo systemctl enable qemu-guest-agent",
      "sudo systemctl start qemu-guest-agent"
    ]
  }
}