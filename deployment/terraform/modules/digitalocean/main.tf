# DigitalOcean downloads the image from the release URL and stores it as a
# custom image in each region.
resource "digitalocean_custom_image" "this" {
  name         = coalesce(var.name, "nixos-${var.image_version}")
  url          = "https://github.com/nixos-contrib/nix-images/releases/download/${var.image_version}/nixos-digitalocean-x86_64-linux.qcow2.gz"
  regions      = var.regions
  distribution = "Unknown"
  description  = "NixOS ${var.image_version} from nixos-contrib/nix-images"
  tags         = var.tags
}
