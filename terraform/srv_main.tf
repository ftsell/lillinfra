resource "hcloud_server" "main" {
  name = "main"
  labels = {
    "ftsell.de/purpose" : "main_server"
    "ftsell.de/public_dns" : "main.srv.${data.hetznerdns_zone.ftsell_de.name}"
    "ftsell.de/firewall" : "main_server"
  }
  server_type        = "cpx31"
  backups            = true
  location           = var.main_location
  image              = data.hcloud_image.debian.id
  ssh_keys           = [hcloud_ssh_key.ftsell.id]
  user_data          = data.template_file.cloud-init-config.rendered
  delete_protection  = var.enable_delete_protection
  rebuild_protection = var.enable_delete_protection

  lifecycle {
    ignore_changes = [image, user_data]
  }
}

resource "hcloud_rdns" "lb1-ipv4" {
  server_id  = hcloud_server.main.id
  dns_ptr    = "${hcloud_server.main.name}.srv.${data.hetznerdns_zone.ftsell_de.name}"
  ip_address = hcloud_server.main.ipv4_address
}

resource "hcloud_rdns" "lb1-ipv6" {
  server_id  = hcloud_server.main.id
  dns_ptr    = "${hcloud_server.main.name}.srv.${data.hetznerdns_zone.ftsell_de.name}"
  ip_address = hcloud_server.main.ipv6_address
}

resource "hetznerdns_record" "lb1-ipv4" {
  zone_id = data.hetznerdns_zone.ftsell_de.id
  type    = "A"
  name    = "${hcloud_server.main.name}.srv"
  value   = hcloud_server.main.ipv4_address
}

resource "hetznerdns_record" "lb1-ipv6" {
  zone_id = data.hetznerdns_zone.ftsell_de.id
  type    = "AAAA"
  name    = "${hcloud_server.main.name}.srv"
  value   = hcloud_server.main.ipv6_address
}
