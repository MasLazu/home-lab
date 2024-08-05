# Proxmox Full-Clone
# ---
# Create a new VM from a clone

variable "vm_count" {
  type    = number
  default = 1
}

variable "vm_name_prefix" {
  type    = string
  default = "ubuntu-24"
}

resource "proxmox_vm_qemu" "ubuntu-24" {
  count = var.vm_count
  
  # VM General Settings
  target_node = "mfaziz"
  vmid = 101 + count.index
  name = "${count.index+1}-${var.vm_name_prefix}"
  desc = "Ubuntu 24 Server"

  # VM Advanced General Settings
  onboot = true 

  # VM OS Settings
  clone = "ubuntu-server-24"

  # VM System Settings
  agent = 1
  
  # VM CPU Settings
  cores = 2
  sockets = 1
  cpu = "host"
  
  # VM Memory Settings
  memory = 4096

  # VM Network Settings
  network {
      bridge = "vmbr0"
      model  = "virtio"
  }

  disks {
    virtio {
      virtio0 {
        disk {
          size = "120G"
          storage = "local"
          format = "qcow2"
        }
      }
    }
    ide {
      ide0 {
        cloudinit {
          storage = "local"
        }
      }
    }
  }

  ssh_user        = "mfaziz"
  ssh_forward_ip  = "192.168.1.20${count.index+1}"
  ssh_private_key = <<EOF
-----BEGIN RSA PRIVATE KEY-----
${file("${path.module}/private_key.txt")}
-----END RSA PRIVATE KEY-----
EOF

  # VM Cloud-Init Settings
  os_type = "cloud-init"

  # (Optional) IP Address and Gateway
  ipconfig0 = "ip=192.168.1.20${count.index+1}/24,gw=192.168.1.254"
  
  # (Optional) Default User
  # ciuser = "your-username"
  
  # (Optional) Add your SSH KEY
  # sshkeys = <<EOF
  # #YOUR-PUBLIC-SSH-KEY
  # EOF
}