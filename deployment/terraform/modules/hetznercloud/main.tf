locals {
  architecture = {
    "aarch64-linux" = "arm"
    "x86_64-linux"  = "x86"
  }
}

# Hetzner can't import images directly. The imager provider writes the release
# image to a temporary server's disk, snapshots it and deletes the server.
resource "imager_image" "this" {
  image_url    = "https://github.com/nixos-contrib/nix-images/releases/download/${var.image_version}/nixos-hetznercloud-${var.system}.raw.xz"
  architecture = local.architecture[var.system]
  location     = var.location
  description  = coalesce(var.name, "nixos-${var.image_version}-${var.system}")

  # Replaces the provider's Talos defaults.
  labels = merge(var.labels, {
    os      = "nixos"
    creator = "nix-images"
    version = var.image_version
  })
}
