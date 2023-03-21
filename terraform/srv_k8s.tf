module "k8s-api-srv" {
  source = "./gen_protected_server"

  server_name    = "k8s-api"
  vm_type        = "cx21"
  server_purpose = "k8s-api-server"
  hcloud_network = {
    network_id = hcloud_network.main-net.id
    ip         = "10.0.0.9"
  }
  root_ssh_key_ids = [ hcloud_ssh_key.ftsell.id ]
  bastion_server_id = hcloud_server.router.id
  enable_delete_protection = var.enable_delete_protection
}

module "k8s-worker" {
  source = "./gen_protected_server"

  server_name    = "k8s-worker${count.index}"
  vm_type        = "cx21"
  server_purpose = "k8s-worker"
  hcloud_network = {
    network_id = hcloud_network.main-net.id
    ip         = "10.0.0.${10 + count.index}"
  }
  root_ssh_key_ids = [ hcloud_ssh_key.ftsell.id ]
  bastion_server_id = hcloud_server.router.id
  enable_delete_protection = var.enable_delete_protection

  count = 2
}
