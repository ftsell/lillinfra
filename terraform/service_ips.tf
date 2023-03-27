// General traffic
module "main_ip" {
  source       = "./service_ip"
  service_name = "main"
  lb_srv_id    = hcloud_server.lb1.id
}
output "main_ip" {
  value = module.main_ip.ip_address
}

// Mail Traffic
module "mail_ip" {
  source       = "./service_ip"
  service_name = "mail"
  lb_srv_id    = hcloud_server.lb1.id
}
output "mail_ip" {
  value = module.mail_ip.ip_address
}
