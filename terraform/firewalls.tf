resource "hcloud_firewall" "lb" {
  name = "load-balancers"
  apply_to {
    label_selector = "ftsell.de/firewall=load-balancers"
  }

  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [ "0.0.0.0/0", "::/0" ]
  }

  rule {
    direction = "in"
    protocol = "tcp"
    port = "22"
    source_ips = [ "0.0.0.0/0", "::/0" ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port = "80"
    source_ips = [ "0.0.0.0/0", "::/0" ]
  }

  rule {
    direction = "in"
    protocol  = "tcp"
    port = "443"
    source_ips = [ "0.0.0.0/0", "::/0" ]
  }
}

resource "hcloud_firewall" "protected_servers" {
  name = "protected-servers"
  apply_to {
    label_selector = "ftsell.de/firewall=protected_servers"
  }

  rule {
    direction = "in"
    protocol  = "icmp"
    source_ips = [ "0.0.0.0/0", "::/0" ]
  }
}
