terraform {
  required_version = ">= 1.3"

  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = ">= 2.0, < 3.0"
    }
  }
}
