// Hetzner Cloud setup
variable "enable_delete_protection" {
  type    = bool
  default = true
}

variable "main_location" {
  type    = string
  default = "fsn1" # frankfurt
}

resource "hcloud_network" "main-net" {
  name              = "main-net"
  ip_range          = "10.0.0.0/16"
  delete_protection = var.enable_delete_protection
}

resource "hcloud_network_subnet" "vm-net" {
  ip_range     = "10.0.0.0/24"
  network_id   = hcloud_network.main-net.id
  network_zone = "eu-central"
  type         = "cloud"
}

resource "hcloud_ssh_key" "ftsell" {
  name       = "ftsell"
  public_key = file("${path.root}/resources/id_rsa.pub")
}

data "hetznerdns_zone" "ftsell_de" {
  name = "ftsell.de"
}
