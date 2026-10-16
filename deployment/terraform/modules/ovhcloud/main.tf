# OVHcloud Public Cloud is OpenStack. The provider downloads the release image
# on the machine running Terraform, then uploads it to Glance.
resource "openstack_images_image_v2" "this" {
  name             = coalesce(var.name, "nixos-${var.image_version}")
  image_source_url = "https://github.com/nixos-contrib/nix-images/releases/download/${var.image_version}/nixos-ovhcloud-x86_64-linux.qcow2"
  container_format = "bare"
  disk_format      = "qcow2"
  visibility       = "private"
  tags             = var.tags

  properties = {
    os_type   = "linux"
    os_distro = "nixos"
  }
}
