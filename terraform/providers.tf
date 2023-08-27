// General terraform configuration

terraform {
  required_version = ">=1.3.9"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">=1.42.1"
    }
    hetznerdns = {
      source  = "timohirt/hetznerdns"
      version = ">=2.2.0"
    }
    template = {
      version = ">=2.2.0"
    }
    local = {
      version = ">=2.3.0"
    }
  }
}
