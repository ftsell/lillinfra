// Hetzner Cloud setup

resource "hcloud_network" "finn-net" {
  name              = "finn-net"
  ip_range          = "10.0.0.0/16"
  delete_protection = var.hcloud_protections
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
  public_key = data.local_file.ftsell_pubkey.content
}

resource "hcloud_server" "nethub" {
  name = "nethub"
  labels = {
    "ftsell.de/purpose" = "ingress-egress"
  }
  server_type = "cx21"
  backups     = true
  location    = "fsn1"
  image       = "debian-11"
  network {
    network_id = hcloud_network.finn-net.id
    ip         = "10.0.0.2"
  }
  ssh_keys           = [hcloud_ssh_key.ftsell.id]
  user_data          = data.template_file.hetzner_vm_config.rendered
  delete_protection  = var.hcloud_protections
  rebuild_protection = var.hcloud_protections
  depends_on         = [hcloud_network_subnet.vm-net, hcloud_ssh_key.ftsell]
}

resource "hcloud_rdns" "nethub4" {
  server_id  = hcloud_server.nethub.id
  dns_ptr    = "nethub.srv.ftsell.de"
  ip_address = hcloud_server.nethub.ipv4_address
}

resource "hcloud_rdns" "nethub6" {
  server_id  = hcloud_server.nethub.id
  dns_ptr    = "nethub.srv.ftsell.de"
  ip_address = hcloud_server.nethub.ipv6_address
}

output "nethub_hcloud_link" {
  value = "https://console.hetzner.cloud/projects/1461749/servers/${hcloud_server.nethub.id}/overview"
}
