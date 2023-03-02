variable "hcloud_protections" {
  description = "Whether Hetzner-Cloud delete protections should be enabled or not"
  type        = bool
  default     = false
}

data "local_file" "ftsell_pubkey" {
  filename = "id_rsa.pub"
}

data "template_file" "hetzner_vm_config" {
  template = file("cloud-config.yml")
  vars = {
    ftsell_pubkey = data.local_file.ftsell_pubkey.content
    ftsell_pwhash = file("password_hash.secret.txt")
  }
}
