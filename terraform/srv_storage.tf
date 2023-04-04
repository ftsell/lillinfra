module "storage-srv" {
  source = "./gen_protected_server"

  server_name      = "storage"
  vm_type          = "cx11"
  server_purpose   = "storage-server"
  root_ssh_key_ids = [hcloud_ssh_key.ftsell.id]
  hcloud_network = {
    network_id = hcloud_network.main-net.id,
    ip         = "10.0.0.8"
  }

  enable_delete_protection = var.enable_delete_protection
  depends_on               = [hcloud_network_subnet.vm-net]
}
