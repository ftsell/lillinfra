resource "hcloud_server" "monitoring" {
  name = "monitoring"
  labels = {
    "ftsell.de/purpose" : "monitoring"
    "ftsell.de/public_dns" : "monitoring.srv.${data.hetznerdns_zone.ftsell_de.name}"
    "ftsell.de/firewall" : "monitoring"
  }
  server_type        = "cpx11"
  location           = var.offsite_location
  backups            = true
  image              = data.hcloud_image.debian.id
  ssh_keys           = [hcloud_ssh_key.ftsell.id]
  user_data          = data.template_file.cloud-init-config.rendered
  delete_protection  = var.enable_delete_protection
  rebuild_protection = var.enable_delete_protection

  lifecycle {
    ignore_changes = [image, user_data]
  }
}

resource "hcloud_rdns" "monitoring-ipv4" {
  server_id  = hcloud_server.monitoring.id
  dns_ptr    = "${hcloud_server.monitoring.name}.srv.${data.hetznerdns_zone.ftsell_de.name}"
  ip_address = hcloud_server.monitoring.ipv4_address
}

resource "hcloud_rdns" "monitoring-ipv6" {
  server_id  = hcloud_server.monitoring.id
  dns_ptr    = "${hcloud_server.monitoring.name}.srv.${data.hetznerdns_zone.ftsell_de.name}"
  ip_address = hcloud_server.monitoring.ipv6_address
}

resource "hetznerdns_record" "monitoring-ipv4" {
  zone_id = data.hetznerdns_zone.ftsell_de.id
  type    = "A"
  name    = "${hcloud_server.monitoring.name}.srv"
  value   = hcloud_server.monitoring.ipv4_address
}

resource "hetznerdns_record" "monitoring-ipv6" {
  zone_id = data.hetznerdns_zone.ftsell_de.id
  type    = "AAAA"
  name    = "${hcloud_server.monitoring.name}.srv"
  value   = hcloud_server.monitoring.ipv6_address
}
