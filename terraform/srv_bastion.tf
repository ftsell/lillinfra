resource "hcloud_server" "bastion-srv" {
  name = "bastion"
  labels = {
    "ftsell.de/purpose" : "firewall"
    "ftsell.de/public_dns" : "bastion.srv.${data.hetznerdns_zone.ftsell_de.name}"
    "ftsell.de/is_firewalled" = false
  }
  server_type = "cpx11"
  backups     = true
  location    = "fsn1" # frankfurt
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

resource "hcloud_rdns" "bastion-ipv4" {
  server_id  = hcloud_server.bastion-srv.id
  dns_ptr    = "${hcloud_server.bastion-srv.name}.srv.${data.hetznerdns_zone.ftsell_de.name}"
  ip_address = hcloud_server.bastion-srv.ipv4_address
}

resource "hcloud_rdns" "bastion-ipv6" {
  server_id  = hcloud_server.bastion-srv.id
  dns_ptr    = "${hcloud_server.bastion-srv.name}.srv.${data.hetznerdns_zone.ftsell_de.name}"
  ip_address = hcloud_server.bastion-srv.ipv6_address
}

resource "hetznerdns_record" "bastion-ipv4" {
  zone_id = data.hetznerdns_zone.ftsell_de.id
  type    = "A"
  name    = "${hcloud_server.bastion-srv.name}.srv"
  value   = hcloud_server.bastion-srv.ipv4_address
}

resource "hetznerdns_record" "bastion-ipv6" {
  zone_id = data.hetznerdns_zone.ftsell_de.id
  type    = "AAAA"
  name    = "${hcloud_server.bastion-srv.name}.srv"
  value   = hcloud_server.bastion-srv.ipv6_address
}
