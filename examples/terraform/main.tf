terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

variable "image_version" {
  description = "Release tag of nixos-contrib/nixos-image to deploy, e.g. v0.1.0"
  type        = string
}

variable "region" {
  type    = string
  default = "fra1"
}

variable "ssh_key_fingerprint" {
  description = "Fingerprint of an SSH key already added to your DigitalOcean account"
  type        = string
}

# DigitalOcean downloads the image from the URL and stores it as a custom image.
# Pinning the tag (instead of releases/latest) means bumping image_version
# replaces the image explicitly.
resource "digitalocean_custom_image" "nixos" {
  name         = "nixos-${var.image_version}"
  url          = "https://github.com/nixos-contrib/nixos-image/releases/download/${var.image_version}/nixos-digitalocean-x86_64-linux.qcow2.gz"
  regions      = [var.region]
  distribution = "Unknown"
}

resource "digitalocean_droplet" "nixos" {
  name   = "nixos"
  image  = digitalocean_custom_image.nixos.id
  region = var.region
  size   = "s-1vcpu-1gb"

  # Required for custom images; the image installs these keys for root.
  ssh_keys = [var.ssh_key_fingerprint]
}

output "ipv4_address" {
  value = digitalocean_droplet.nixos.ipv4_address
}
