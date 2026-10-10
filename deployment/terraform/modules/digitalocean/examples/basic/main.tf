module "digitalocean_nixos_image" {
  source = "../.."

  regions = [var.region]
}

resource "digitalocean_droplet" "nixos" {
  name   = "nixos"
  image  = module.digitalocean_nixos_image.image_id
  region = var.region
  size   = "s-1vcpu-1gb"

  # Required for custom images; the image installs these keys for root.
  ssh_keys = [var.ssh_key_fingerprint]

  # The droplet is updated with nixos-rebuild from then on; don't recreate it
  # when a newer image is released.
  lifecycle {
    ignore_changes = [image]
  }
}
