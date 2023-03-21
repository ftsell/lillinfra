module "mail_ip" {
  source         = "./service_ip"
  service_name   = "mail"
  bastion_srv_id = hcloud_server.router.id
}

output "mail_ip" {
  value = module.mail_ip.ip_address
}
