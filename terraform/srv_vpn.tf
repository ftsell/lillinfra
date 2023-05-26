resource "hcloud_server" "vpn" {
  name = "vpn"
  labels = {
    "ftsell.de/purpose" : "vpn"
    "ftsell.de/public_dns" : "vpn.srv.${data.hetznerdns_zone.ftsell_de.name}"
    "ftsell.de/firewall" : "vpn"
  }
  server_type        = "cax11"
  location           = var.main_location
  backups            = true
  image              = data.hcloud_image.debian_arm.id
  ssh_keys           = [hcloud_ssh_key.ftsell.id]
  user_data          = data.template_file.cloud-init-config.rendered
  delete_protection  = var.enable_delete_protection
  rebuild_protection = var.enable_delete_protection

  lifecycle {
    ignore_changes = [image, user_data]
  }
}

resource "hcloud_rdns" "vpn-ipv4" {
  server_id  = hcloud_server.vpn.id
  dns_ptr    = "${hcloud_server.vpn.name}.srv.${data.hetznerdns_zone.ftsell_de.name}"
  ip_address = hcloud_server.vpn.ipv4_address
}

resource "hcloud_rdns" "vpn-ipv6" {
  server_id  = hcloud_server.vpn.id
  dns_ptr    = "${hcloud_server.vpn.name}.srv.${data.hetznerdns_zone.ftsell_de.name}"
  ip_address = hcloud_server.vpn.ipv6_address
}

resource "hetznerdns_record" "vpn-ipv4" {
  zone_id = data.hetznerdns_zone.ftsell_de.id
  type    = "A"
  name    = "${hcloud_server.vpn.name}.srv"
  value   = hcloud_server.vpn.ipv4_address
}

resource "hetznerdns_record" "vpn-ipv6" {
  zone_id = data.hetznerdns_zone.ftsell_de.id
  type    = "AAAA"
  name    = "${hcloud_server.vpn.name}.srv"
  value   = hcloud_server.vpn.ipv6_address
}
