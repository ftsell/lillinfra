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
  depends_on         = [hcloud_network_subnet.vm-net]
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

data "hetznerdns_zone" "ftsell_de" {
  name = "ftsell.de"
}

resource "hetznerdns_record" "nethub_srv_ftsell_de-ipv4" {
  zone_id = data.hetznerdns_zone.ftsell_de.id
  type    = "A"
  name    = "nethub.srv"
  value   = hcloud_server.nethub.ipv4_address
}

resource "hetznerdns_record" "nethub_srv_ftsell_de-ipv6" {
  zone_id = data.hetznerdns_zone.ftsell_de.id
  type    = "AAAA"
  name    = "nethub.srv"
  value   = hcloud_server.nethub.ipv6_address
}

output "nethub_hcloud_link" {
  value = "https://console.hetzner.cloud/projects/1461749/servers/${hcloud_server.nethub.id}/overview"
}
