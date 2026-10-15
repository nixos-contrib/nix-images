terraform {
  required_version = ">= 1.3"

  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = ">= 1.45, < 2.0"
    }
    imager = {
      source  = "hcloud-talos/imager"
      version = ">= 1.0, < 2.0"
    }
  }
}
