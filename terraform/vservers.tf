module "bastion-server" {
  source = "./gen_vserver"

  server_name        = "bastion"
  server_purpose     = "bastion"
  server_vm_type     = "cx21"
  private_network_ip = "10.0.0.2"

  ssh_key_id         = hcloud_ssh_key.ftsell.id
  private_network_id = hcloud_network.finn-net.id

  depends_on = [hcloud_network_subnet.vm-net]
}

output "bastion_hcloud_link" {
  value = module.bastion-server.hcloud_link
}
