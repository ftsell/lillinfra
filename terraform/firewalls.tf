resource "hcloud_firewall" "main" {
  name = "main_server"
  apply_to {
    label_selector = "ftsell.de/firewall=main_server"
  }

  rule {
    direction       = "in"
    protocol        = "icmp"
    source_ips      = ["0.0.0.0/0", "::/0"]
    destination_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    description     = "SSH"
    direction       = "in"
    protocol        = "tcp"
    port            = "22"
    source_ips      = ["0.0.0.0/0", "::/0"]
    destination_ips = ["${hcloud_server.main.ipv4_address}/32", "${hcloud_server.main.ipv6_address}/128"]
  }

  rule {
    description     = "Kubernetes API-Server"
    direction       = "in"
    protocol        = "tcp"
    port            = "6443"
    source_ips      = ["0.0.0.0/0", "::/0"]
    destination_ips = ["${hcloud_server.main.ipv4_address}/32", "${hcloud_server.main.ipv6_address}/128"]
  }

  rule {
    description     = "HTTP"
    direction       = "in"
    protocol        = "tcp"
    port            = "80"
    source_ips      = ["0.0.0.0/0", "::/0"]
    destination_ips = ["${module.main_ip.ip_address}/32", hcloud_server.main.ipv6_network]
  }

  rule {
    description     = "HTTPS"
    direction       = "in"
    protocol        = "tcp"
    port            = "443"
    source_ips      = ["0.0.0.0/0", "::/0"]
    destination_ips = ["${module.main_ip.ip_address}/32", hcloud_server.main.ipv6_network]
  }

  rule {
    description     = "Pixelflut"
    direction       = "in"
    protocol        = "tcp"
    port            = "9876"
    source_ips      = ["0.0.0.0/0", "::/0"]
    destination_ips = ["${module.main_ip.ip_address}/32", hcloud_server.main.ipv6_network]
  }

  rule {
    description     = "Pixelflut"
    direction       = "in"
    protocol        = "udp"
    port            = "9876"
    source_ips      = ["0.0.0.0/0", "::/0"]
    destination_ips = ["${module.main_ip.ip_address}/32", hcloud_server.main.ipv6_network]
  }

  rule {
    description     = "SMTP"
    direction       = "in"
    protocol        = "tcp"
    port            = "25"
    source_ips      = ["0.0.0.0/0", "::/0"]
    destination_ips = ["${module.mail_ip.ip_address}/32", hcloud_server.main.ipv6_network]
  }

  rule {
    description     = "SMTP Submission"
    direction       = "in"
    protocol        = "tcp"
    port            = "587"
    source_ips      = ["0.0.0.0/0", "::/0"]
    destination_ips = ["${module.mail_ip.ip_address}/32", hcloud_server.main.ipv6_network]
  }

  rule {
    description     = "IMAPs"
    direction       = "in"
    protocol        = "tcp"
    port            = "993"
    source_ips      = ["0.0.0.0/0", "::/0"]
    destination_ips = ["${module.mail_ip.ip_address}/32", hcloud_server.main.ipv6_network]
  }

  rule {
    description     = "ManageSieve"
    direction       = "in"
    protocol        = "tcp"
    port            = "4190"
    source_ips      = ["0.0.0.0/0", "::/0"]
    destination_ips = ["${module.mail_ip.ip_address}/32", hcloud_server.main.ipv6_network]
  }
}

resource "hcloud_firewall" "monitoring" {
  name = "monitoring"
  apply_to {
    label_selector = "ftsell.de/firewall=monitoring"
  }

  rule {
    direction       = "in"
    protocol        = "icmp"
    source_ips      = ["0.0.0.0/0", "::/0"]
    destination_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "80"
    source_ips = ["0.0.0.0/0", "::/0"]
  }

  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "443"
    source_ips = ["0.0.0.0/0", "::/0"]
  }
}

resource "hcloud_firewall" "vpn" {
  name = "vpn"
  apply_to {
    label_selector = "ftsell.de/firewall=vpn"
  }

  rule {
    direction  = "in"
    protocol   = "icmp"
    source_ips = ["0.0.0.0/0", "::/0"]
    #destination_ips = ["0.0.0.0/0", "::/0"]
  }
}
