data "local_file" "ftsell_id_rsa_pub" {
  filename = "${path.root}/resources/id_rsa.pub"
}

data "template_file" "cloud-init-config" {
  template = file("${path.root}/resources/cloud-config.yml")
  vars = {
    ftsell_pubkey = data.local_file.ftsell_id_rsa_pub.content
    ftsell_pwhash = trimspace(file("${path.root}/resources/password_hash.secret.txt"))
  }
}

data "hcloud_image" "debian" {
  name        = "debian-11"
  with_status = ["available"]
  most_recent = true
}
