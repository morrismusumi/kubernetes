variable "cloudinit_template_name" {
    type = string 
}

variable "proxmox_node" {
    type = string
}

variable "ssh_key" {
  type = string 
  sensitive = true
}

resource "proxmox_vm_qemu" "k8s-1" {
  count = 3
  name = "k8s-1${count.index + 1}"
  target_node = var.proxmox_node
  clone = var.cloudinit_template_name
  agent = 1
  os_type = "cloud-init"
  cores = 4
  sockets = 1
  cpu = "host"
  memory = 4096
  scsihw = "virtio-scsi-pci"
  bootdisk = "scsi0"

  disk {
    slot = 0
    size = "40G"
    type = "scsi"
    storage = "pve1"
  }

  network {
    model = "virtio"
    bridge = "vmbr2"
  }
  
  lifecycle {
    ignore_changes = [
      network,
    ]
  }

  ipconfig0 = "ip=172.20.0.20${count.index + 1}/24,gw=172.20.0.1"
  nameserver = "172.20.0.31"
  
  sshkeys = <<EOF
  ${var.ssh_key}
  EOF

}
















