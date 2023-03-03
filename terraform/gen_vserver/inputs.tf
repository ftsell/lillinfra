variable "server_name" {
  description = "Name of the Server"
  type        = string
}

variable "server_purpose" {
  description = "Purpose of this server"
  type        = string
}

variable "server_vm_type" {
  description = "VM type of the server (e.g. xc21)"
  type        = string
}

variable "server_vm_location" {
  description = "Hetzner location at which the server should be hosted"
  type        = string
  default     = "fsn1" // frankfurt
}

variable "private_network_id" {
  description = "ID of the Hetzner cloud network to which this server should be attached"
  type        = string
}

variable "private_network_ip" {
  description = "IP address of this server in the private cloud network"
  type        = string
}

variable "ssh_key_id" {
  description = "ID of the Hetzner cloud ssh key that should be registered as root key"
  type        = string
  default     = null
}

variable "enable_delete_protections" {
  description = "Whether delete and rebuild protections should be turned on"
  type        = bool
  default     = true
}

variable "dns_zone" {
  description = "DNS zone under which this server is running"
  type        = string
  default     = "ftsell.de"
}

variable "server_image" {
  description = "Installation image to use"
  type        = string
  default     = "debian-11"
}
