// Hetzner Cloud setup

resource "hcloud_network" "finn-net" {
  name              = "finn-net"
  ip_range          = "10.0.0.0/16"
  delete_protection = true
}

resource "hcloud_network_subnet" "vm-net" {
  ip_range     = "10.0.0.0/24"
  network_id   = hcloud_network.finn-net.id
  network_zone = "eu-central"
  type         = "cloud"
  depends_on   = [hcloud_network.finn-net]
}

resource "hcloud_ssh_key" "ftsell" {
  name       = "ftsell"
  public_key = file("${path.root}/resources/id_rsa.pub")
}
