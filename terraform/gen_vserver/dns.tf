resource "hcloud_rdns" "server-ipv4" {
  server_id  = hcloud_server.server.id
  dns_ptr    = "${var.server_name}.srv.${var.dns_zone}"
  ip_address = hcloud_server.server.ipv4_address
}

resource "hcloud_rdns" "server-ipv6" {
  server_id  = hcloud_server.server.id
  dns_ptr    = "${var.server_name}.srv.${var.dns_zone}"
  ip_address = hcloud_server.server.ipv6_address
}

resource "hetznerdns_record" "server-ipv4" {
  zone_id = data.hetznerdns_zone.dns_zone.id
  type    = "A"
  name    = "${var.server_name}.srv"
  value   = hcloud_server.server.ipv4_address
}

resource "hetznerdns_record" "server-ipv6" {
  zone_id = data.hetznerdns_zone.dns_zone.id
  type    = "AAAA"
  name    = "${var.server_name}.srv"
  value   = hcloud_server.server.ipv6_address
}
