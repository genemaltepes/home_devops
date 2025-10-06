# TF vars for spinning up VMs

variable "pm_tls_insecure" {
  description = "Set to true to ignore certificate errors"
  type        = bool
  default     = true
}

#Establish which Proxmox host you'd like to spin a VM up on
variable "proxmox_host" {
    default = "192.168.1.192"
}

#Establish which nic you would like to utilize
variable "nic_name" {
    default = "vmbr0"
}

# Needed for remote exec
variable "ssh_keys" {
    default = <<EOF
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBVQsTMfA6sxM8jvEt5SmjKEz0VxPDKu00VyivHSKb/6 gene@desktop
EOF
}

variable "k3s_pve_node" {
  description = "Proxmox node for k3s"
  default = "pve"
}

variable "k3s_master_vm_ids" {
  type = list(number)
  default = [210, 211, 212]
}

variable "k3s_worker_vm_ids" {
  type = list(number)
  default = [240, 241, 242]
}

variable "k3s_master_count" {
  description = "Number of k3s masters to create"
  default = 3
}

variable "k3s_worker_count" {
  description = "Number of k3s workers to create"
  default = 3
}

variable "k3s_master_cores" {
  description = "Number of CPU cores for each k3s master"
  default = 2
}

variable "k3s_master_mem" {
  description = "Memory (in MB) to assign to each k3s master"
  default = 8192
}

variable "k3s_worker_cores" {
  description = "Number of CPU cores for each k3s worker"
  default = 2
}

variable "k3s_worker_mem" {
  description = "Memory (in MB) to assign to each k3s worker"
  default = 8192
}

variable "k3s_user" {
  description = "Used by Ansible"
  default = "ansible"
}

variable "k3s_nameserver" {
  default = "192.168.1.1 8.8.8.8"
}

variable "k3s_gateway" {
  default = "192.168.1.1"
}

variable "k3s_master_ip_addresses" {
  type = list(string)
  default = ["192.168.1.210/24", "192.168.1.211/24", "192.168.1.212/24"]
}

variable "k3s_worker_ip_addresses" {
  type = list(string)
  default = ["192.168.1.240/24", "192.168.1.241/24", "192.168.1.242/24"]
}

variable "k3s_node_disk_size" {
  default = "20G"
}

variable "k3s_node_disk_storage" {
  default = "local-lvm"
}

variable "k3s_template_name" {
  default = "debian12-cloudinit"
}

#variable "k3s_ssh_key_file" {
#  default = "ansible_ed25519.pub"
#}

# I don't have VLANs set up
# #Establish the VLAN you'd like to use 
# variable "vlan_num" {
#     default = "place_vlan_number_here"
# }

#Blank var for use by terraform.tfvars
variable "token_secret" {
}

#Blank var for use by terraform.tfvars
variable "token_id" {
}
