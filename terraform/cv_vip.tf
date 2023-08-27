resource "hcloud_floating_ip" "cv_vip" {
  type        = "ipv6"
  name        = "cv_vip"
  description = "IPv6 block for virtual IP routing for my traceroute CV"
  server_id   = hcloud_server.main.id
}

output "cv_vip_base" {
  value = hcloud_floating_ip.cv_vip.ip_address
}
