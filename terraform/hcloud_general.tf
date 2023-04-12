// Hetzner Cloud setup
variable "enable_delete_protection" {
  type    = bool
  default = true
}

variable "main_location" {
  type    = string
  default = "fsn1" # frankfurt
}

variable "offsite_location" {
  type    = string
  default = "hel1" # helsinki
}

resource "hcloud_ssh_key" "ftsell" {
  name       = "ftsell"
  public_key = file("${path.root}/resources/id_rsa.pub")
}

data "hetznerdns_zone" "ftsell_de" {
  name = "ftsell.de"
}
