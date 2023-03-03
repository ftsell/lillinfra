data "template_file" "cloud-config" {
  template = file("${path.root}/resources/cloud-config.yml")
  vars = {
    ftsell_pubkey = file("${path.root}/resources/id_rsa.pub")
    ftsell_pwhash = file("${path.root}/resources/password_hash.secret.txt")
  }
}

data "hetznerdns_zone" "dns_zone" {
  name = var.dns_zone
}
