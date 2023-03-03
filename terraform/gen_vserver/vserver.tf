resource "hcloud_server" "server" {
  name = var.server_name
  labels = {
    "ftsell.de/purpose" = var.server_purpose
  }
  server_type = var.server_vm_type
  backups     = true
  location    = var.server_vm_location
  image       = var.server_image
  network {
    network_id = var.private_network_id
    ip         = var.private_network_ip
  }
  ssh_keys           = var.ssh_key_id != null ? [var.ssh_key_id] : null
  user_data          = data.template_file.cloud-config.rendered
  delete_protection  = var.enable_delete_protections
  rebuild_protection = var.enable_delete_protections
}
