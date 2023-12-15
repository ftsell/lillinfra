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

data "hcloud_image" "debian_x86" {
  name              = "debian-12"
  with_status       = ["available"]
  with_architecture = "x86"
  most_recent       = true
}

data "hcloud_image" "debian_arm" {
  name              = "debian-11"
  with_status       = ["available"]
  with_architecture = "arm"
  most_recent       = true
}
