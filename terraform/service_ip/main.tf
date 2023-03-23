variable "lb_srv_id" {
  type = number
}

variable "service_name" {
  type = string
}

data "hetznerdns_zone" "ftsell_de" {
  name = "ftsell.de"
}

resource "hcloud_floating_ip" "main" {
  name      = var.service_name
  type      = "ipv4"
  server_id = var.lb_srv_id
  labels = {
    "ftsell.de/dns" : "${var.service_name}.svc.${data.hetznerdns_zone.ftsell_de.name}"
  }
}

resource "hcloud_rdns" "main" {
  floating_ip_id = hcloud_floating_ip.main.id
  dns_ptr        = "${var.service_name}.svc.${data.hetznerdns_zone.ftsell_de.name}"
  ip_address     = hcloud_floating_ip.main.ip_address
}

resource "hetznerdns_record" "main" {
  zone_id = data.hetznerdns_zone.ftsell_de.id
  type    = "A"
  name    = "${var.service_name}.svc"
  value   = hcloud_floating_ip.main.ip_address
}

output "ip_address" {
  value = hcloud_floating_ip.main.ip_address
}

output "dns" {
  value = "${var.service_name}.svc.${data.hetznerdns_zone.ftsell_de.name}"
}
