variable "admin_username" {
  description = "Admin username for the VM"
  type        = string
}

variable "admin_password" {
  description = "Admin password for the VM"
  type        = string
  sensitive   = true
}

variable "ssh_public_key" {
  description = "Pubkey"
  type        = string
  default     = ""
}

variable "vm_count" {
  description = "Number of virtual machines to create."
  default     = 1
}
