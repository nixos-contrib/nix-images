# Credentials and region come from the OS_* environment variables set by the
# openrc.sh file of a Public Cloud user.
provider "openstack" {}

module "ovhcloud_nixos_image" {
  source = "../.."
}

resource "openstack_compute_keypair_v2" "nixos" {
  name       = "nixos"
  public_key = var.ssh_public_key
}

resource "openstack_compute_instance_v2" "nixos" {
  name        = "nixos"
  image_id    = module.ovhcloud_nixos_image.id
  flavor_name = "d2-2"
  key_pair    = openstack_compute_keypair_v2.nixos.name

  # Ext-Net is OVHcloud's public network.
  network {
    name = "Ext-Net"
  }

  # The instance is updated with nixos-rebuild from then on; don't recreate it
  # when a newer image is released.
  lifecycle {
    ignore_changes = [image_id]
  }
}
