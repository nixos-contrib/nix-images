module "hetznercloud_nixos_image" {
  source = "../.."

  system = "aarch64-linux"
}

resource "hcloud_ssh_key" "this" {
  name       = "nixos"
  public_key = var.ssh_public_key
}

resource "hcloud_server" "nixos" {
  name        = "nixos"
  image       = module.hetznercloud_nixos_image.id
  server_type = "cax11"
  location    = var.location

  # The image installs these keys for root.
  ssh_keys = [hcloud_ssh_key.this.id]

  # The server is updated with nixos-rebuild from then on; don't recreate it
  # when a newer image is released.
  lifecycle {
    ignore_changes = [image]
  }
}
