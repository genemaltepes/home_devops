terraform {
  required_providers {
    proxmox = {
      source = "telmate/proxmox"
      version = "3.0.1-rc6"
    }
    #ansible = {
	#  source  = "ansible/ansible"
    #  version = "~> 1.3.0"      
    #}
  }
}

provider "proxmox" {
  pm_api_url = "https://${var.proxmox_host}:8006/api2/json"  
  pm_api_token_id = var.token_id
  pm_api_token_secret = var.token_secret
  pm_tls_insecure = var.pm_tls_insecure
  
  pm_log_enable = true
  pm_log_file   = "terraform-plugin-proxmox.log"
  pm_log_levels = {
    _default    = "debug"
    _capturelog = ""
  }
}
