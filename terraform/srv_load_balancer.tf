resource "hcloud_server" "lb1" {
  name = "lb1"
  labels = {
    "ftsell.de/purpose" : "load_balancer"
    "ftsell.de/public_dns" : "lb1.srv.${data.hetznerdns_zone.ftsell_de.name}"
    "ftsell.de/firewall": "load-balancers"
  }
  server_type = "cpx11"
  backups     = true
  location    = var.main_location
  image       = "debian-11"
  network {
    network_id = hcloud_network.main-net.id
    ip         = "10.0.0.2"
  }
  ssh_keys = [ hcloud_ssh_key.ftsell.id ]
  user_data          = data.template_file.cloud-init-config.rendered
  delete_protection  = var.enable_delete_protection
  rebuild_protection = var.enable_delete_protection

  depends_on = [hcloud_network_subnet.vm-net]
  lifecycle {
    ignore_changes = [image, user_data]
  }
}

resource "hcloud_rdns" "lb1-ipv4" {
  server_id  = hcloud_server.lb1.id
  dns_ptr    = "${hcloud_server.lb1.name}.srv.${data.hetznerdns_zone.ftsell_de.name}"
  ip_address = hcloud_server.lb1.ipv4_address
}

resource "hcloud_rdns" "lb1-ipv6" {
  server_id  = hcloud_server.lb1.id
  dns_ptr    = "${hcloud_server.lb1.name}.srv.${data.hetznerdns_zone.ftsell_de.name}"
  ip_address = hcloud_server.lb1.ipv6_address
}

resource "hetznerdns_record" "lb1-ipv4" {
  zone_id = data.hetznerdns_zone.ftsell_de.id
  type    = "A"
  name    = "${hcloud_server.lb1.name}.srv"
  value   = hcloud_server.lb1.ipv4_address
}

resource "hetznerdns_record" "lb1-ipv6" {
  zone_id = data.hetznerdns_zone.ftsell_de.id
  type    = "AAAA"
  name    = "${hcloud_server.lb1.name}.srv"
  value   = hcloud_server.lb1.ipv6_address
}
