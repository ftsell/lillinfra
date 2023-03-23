variable "server_name" {
  type = string
}

variable "vm_type" {
  type = string
}

variable "server_purpose" {
  type = string
}

variable "hcloud_network" {
  type = object({
    network_id : string,
    ip : string
  })
}

variable "root_ssh_key_ids" {
  type = list(number)
}

variable "enable_delete_protection" {
  type = bool
}
