resource "proxmox_vm_qemu" "k3s_master" {
    count = var.k3s_master_count
    name = "k3s-master-${count.index}"
    vmid = var.k3s_master_vm_ids[count.index]
    desc = "K3S Master Node"
    ipconfig0 = "gw=${var.k3s_gateway},ip=${var.k3s_master_ip_addresses[count.index]}"
    nameserver = var.k3s_nameserver
    target_node = var.k3s_pve_node
    onboot = true
    clone = var.k3s_template_name
    agent = 1
    ciuser = var.k3s_user
    memory = var.k3s_master_mem
    cores = var.k3s_master_cores    
    os_type = "cloud-init"
    cpu_type = "host"
    scsihw = "virtio-scsi-single"
    sshkeys = var.ssh_keys

    cicustom   = "vendor=local:snippets/qemu-guest-agent.yml" # /var/lib/vz/snippets/qemu-guest-agent.yml
    ciupgrade  = true	
    
   #sshkeys = file("${path.module}/files/${var.k3s_ssh_key_file}")
    
    # Most cloud-init images require a serial device for their display
    serial {
	id = 0
    }
  
    # Setup the disk
    disks {
    scsi {
      scsi0 {
        disk {
          size = var.k3s_node_disk_size
          storage  = var.k3s_node_disk_storage
          discard  = true
          iothread = true
        }
      }
    }
    ide {
      # Some images require a cloud-init disk on the IDE controller, others on the SCSI or SATA controller
      ide1 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }

    network {
		id = 0
        model = "virtio"
        bridge = var.nic_name	     
    }

    # Setup the ip address using cloud-init.
    boot = "order=scsi0"
    skip_ipv6 = true

    lifecycle {
      ignore_changes = [
        disks,
        target_node,
        sshkeys,
        network
      ]
    }
}

resource "proxmox_vm_qemu" "k3s_worker" {
    count = var.k3s_worker_count
    name = "k3s-worker-${count.index}"
    vmid = var.k3s_worker_vm_ids[count.index]
    desc = "K3S Worker Node"
    ipconfig0 = "gw=${var.k3s_gateway},ip=${var.k3s_worker_ip_addresses[count.index]}"
    nameserver = var.k3s_nameserver
    target_node = var.k3s_pve_node
    onboot = true
    clone = var.k3s_template_name
    agent = 1
    ciuser = var.k3s_user
    memory = var.k3s_worker_mem
    cores = var.k3s_worker_cores    
    os_type = "cloud-init"
    cpu_type = "host"
    scsihw = "virtio-scsi-single"
    sshkeys = var.ssh_keys
	
    cicustom   = "vendor=local:snippets/qemu-guest-agent.yml" # /var/lib/vz/snippets/qemu-guest-agent.yml
    ciupgrade  = true
 
    #sshkeys = file("${path.module}/files/${var.k3s_ssh_key_file}")
    
    # Most cloud-init images require a serial device for their display
    serial {
	id = 0
    }

    # Setup the disk
    disks {
    scsi {
      scsi0 {
        disk {
          size = var.k3s_node_disk_size
          storage  = var.k3s_node_disk_storage
          discard  = true
          iothread = true
        }
      }
    }
    ide {
      # Some images require a cloud-init disk on the IDE controller, others on the SCSI or SATA controller
      ide1 {
        cloudinit {
          storage = "local-lvm"
        }
      }
    }
  }

    network {
		id = 0
        model = "virtio"
        bridge = var.nic_name	    
    }

    # Setup the ip address using cloud-init.
    boot = "order=scsi0"
    skip_ipv6 = true

    lifecycle {
      ignore_changes = [
        disks,
        target_node,
        sshkeys,
        network
      ]
    }
}

# Controlled delay per VM
resource "time_sleep" "delay" {
  count           = 6
  create_duration = "${10 + count.index * 10}s"
  depends_on      = [proxmox_vm_qemu.k3s_master, proxmox_vm_qemu.k3s_worker]
}

resource "null_resource" "update_known_hosts" {
  # The trigger ensures this resource is re-created every time the VM IPs change.
  #triggers = {
  #  vm_ips = join(",", output.vm_ips)
  #}
  depends_on = [time_sleep.delay]

  provisioner "local-exec" {
    # The command will first clean the old entries and then add the new ones.
    command = <<-EOT
      known_hosts_file="$HOME/.ssh/known_hosts"
      
      # Clear old host keys to avoid host key verification failures.
      # This example removes all keys associated with any of the IP addresses.
      for ip in ${join(" ", var.vm_ips)}; do
        ssh-keygen -R "$ip" -f "$known_hosts_file"
      done

      # Add new host keys from the re-provisioned VMs.
      for ip in ${join(" ", var.vm_ips)}; do
        ssh-keyscan "$ip" >> "$known_hosts_file"
      done
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
  
}
#data "template_file" "k3s" {
#  template = file("./templates/k3s.tpl")
#  vars = {
#    k3s_master_ip = "${join("\n", [for instance in proxmox_vm_qemu.k3s_master : join("", [instance.name, " ansible_host=", instance.default_ipv4_address])])}"
#    k3s_node_ip   = "${join("\n", [for instance in proxmox_vm_qemu.k3s_workers : join("", [instance.name, " ansible_host=", instance.default_ipv4_address])])}"
#  }
#}
#
#resource "local_file" "k3s_file" {
#  content  = data.template_file.k3s.rendered
#  filename = "../../inventory/k3s"
#}
#
#output "Master-IPS" {
#  value = ["${proxmox_vm_qemu.k3s_master.*.default_ipv4_address}"]
#}
#output "worker-IPS" {
#  value = ["${proxmox_vm_qemu.k3s_workers.*.default_ipv4_address}"]
#}

