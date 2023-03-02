// General terraform configuration

terraform {
  required_version = ">=1.3.9"
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">=1.36.2"
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

provider "hcloud" {
  token = var.hcloud_token
}

provider "hetznerdns" {
  apitoken = var.hetznerdns_token
}
