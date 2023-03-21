resource "hcloud_server" "server" {
  name = var.server_name
  labels = {
    "ftsell.de/purpose" : var.server_purpose
    "ftsell.de/public_ipv4" : hcloud_floating_ip.server_ip.ip_address
    "ftsell.de/public_dns" : "${var.server_name}.srv.${data.hetznerdns_zone.ftsell_de.name}"
    "ftsell.de/is_firewalled" = true
  }
  server_type = var.vm_type
  backups     = true
  location    = "fsn1" # frankfurt
  image       = "debian-11"
  public_net {
    ipv4_enabled = false
    ipv6_enabled = false
  }
  network {
    network_id = var.hcloud_network.network_id
    ip         = var.hcloud_network.ip
  }
  ssh_keys           = var.root_ssh_key_ids
  user_data          = data.cloudinit_config.cloud-config.rendered
  delete_protection  = false
  rebuild_protection = false

  lifecycle {
    ignore_changes = [image, user_data]
  }
}

resource "hcloud_floating_ip" "server_ip" {
  name          = var.server_name
  type          = "ipv4"
  home_location = "fsn1"
  labels = {
    "ftsell.de/dns" : "${var.server_name}.srv.${data.hetznerdns_zone.ftsell_de.name}"
  }
}

resource "hcloud_floating_ip_assignment" "server_ip" {
  floating_ip_id = hcloud_floating_ip.server_ip.id
  server_id      = var.bastion_server_id
}

resource "hcloud_rdns" "server_ipv4" {
  floating_ip_id = hcloud_floating_ip.server_ip.id
  dns_ptr        = "${hcloud_server.server.name}.srv.${data.hetznerdns_zone.ftsell_de.name}"
  ip_address     = hcloud_floating_ip.server_ip.ip_address
}

resource "hetznerdns_record" "server_ipv4" {
  zone_id = data.hetznerdns_zone.ftsell_de.id
  type    = "A"
  name    = "${var.server_name}.srv"
  value   = hcloud_floating_ip.server_ip.ip_address
}
