resource "hcloud_server" "server" {
  name   = var.server_name
  labels = {
    "ftsell.de/purpose" : var.server_purpose
    "ftsell.de/public_dns" : "${var.server_name}.srv.${data.hetznerdns_zone.ftsell_de.name}"
    "ftsell.de/firewall" : "protected_servers"
  }
  server_type = var.vm_type
  backups     = true
  location    = "fsn1" # frankfurt
  image       = "debian-11"
  network {
    network_id = var.hcloud_network.network_id
    ip         = var.hcloud_network.ip
  }
  ssh_keys           = var.root_ssh_key_ids
  user_data          = data.cloudinit_config.cloud-config.rendered
  delete_protection  = var.enable_delete_protection
  rebuild_protection = var.enable_delete_protection

  lifecycle {
    ignore_changes = [image, user_data]
  }
}

resource "hcloud_rdns" "server_ipv4" {
  server_id  = hcloud_server.server.id
  dns_ptr    = "${hcloud_server.server.name}.srv.${data.hetznerdns_zone.ftsell_de.name}"
  ip_address = hcloud_server.server.ipv4_address
}

resource "hcloud_rdns" "server_ipv6" {
  server_id  = hcloud_server.server.id
  dns_ptr    = "${hcloud_server.server.name}.srv.${data.hetznerdns_zone.ftsell_de.name}"
  ip_address = hcloud_server.server.ipv6_address
}

resource "hetznerdns_record" "server_ipv4" {
  zone_id = data.hetznerdns_zone.ftsell_de.id
  type    = "A"
  name    = "${var.server_name}.srv"
  value   = hcloud_server.server.ipv4_address
}

resource "hetznerdns_record" "server_ipv6" {
  zone_id = data.hetznerdns_zone.ftsell_de.id
  type    = "AAAA"
  name    = "${var.server_name}.srv"
  value   = hcloud_server.server.ipv6_address
}
