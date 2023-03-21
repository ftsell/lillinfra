data "hetznerdns_zone" "ftsell_de" {
  name = "ftsell.de"
}

data "cloudinit_config" "cloud-config" {
  base64_encode = false
  gzip          = false

  part {
    filename     = "basic-config.yml"
    content_type = "cloud-config"
    content = templatefile("${path.root}/resources/cloud-config.yml", {
      ftsell_pubkey    = trimspace(file("${path.root}/resources/id_rsa.pub"))
      ftsell_pwhash    = trimspace(file("${path.root}/resources/password_hash.secret.txt"))
    })
  }
}
