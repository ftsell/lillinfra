module "k8s-api" {
  source = "./gen_protected_server"

  server_name      = "k8s-api"
  vm_type          = "cpx11"
  server_purpose   = "k8s-api-server"
  root_ssh_key_ids = [hcloud_ssh_key.ftsell.id]
  hcloud_network = {
    network_id = hcloud_network.main-net.id,
    ip         = "10.0.0.9"
  }

  enable_delete_protection = var.enable_delete_protection
  depends_on               = [hcloud_network_subnet.vm-net]
}

module "k8s-worker" {
  source = "./gen_protected_server"

  server_name      = "k8s-worker${count.index + 1}"
  vm_type          = "cpx31"
  server_purpose   = "k8s-worker"
  root_ssh_key_ids = [hcloud_ssh_key.ftsell.id]
  hcloud_network = {
    network_id = hcloud_network.main-net.id,
    ip         = "10.0.0.${10 + count.index + 1}"
  }

  enable_delete_protection = var.enable_delete_protection
  depends_on               = [hcloud_network_subnet.vm-net]
  count                    = 1
}
