# ovhcloud

Uploads the NixOS OVHcloud image from a release of this repository to a Public
Cloud project. Instances are left to the caller; see
[examples/basic](examples/basic) for a complete setup.

```hcl
module "ovhcloud_nixos_image" {
  source = "github.com/nixos-contrib/nix-images//deployment/terraform/modules/ovhcloud?ref=v0.1.0"
}

resource "openstack_compute_instance_v2" "nixos" {
  image_id    = module.ovhcloud_nixos_image.id
  key_pair    = openstack_compute_keypair_v2.nixos.name
  flavor_name = "d2-2"
  # ...

  lifecycle {
    ignore_changes = [image_id]
  }
}
```

Public Cloud is OpenStack, so the module uses the OpenStack provider rather
than the OVH one. Configure it with the credentials of a Public Cloud user,
using the `openrc.sh` file from the OVHcloud control panel (**Public Cloud →
Users & Roles**), which sets the `OS_*` environment variables. The image is
x86_64 only, which covers every Public Cloud flavor except the Arm ones.

The image is uploaded with some of the properties from OVHcloud's
[upload your own image](https://docs.ovhcloud.com/en/guides/public-cloud/compute/upload-own-image)
guide: the QEMU guest agent, and `root` as the login user. It keeps the default
virtio block disk, not the guide's virtio SCSI, because the image installs GRUB
to `/dev/vda`.

Images belong to a single region, which the provider takes from
`OS_REGION_NAME` in the `openrc.sh` file. Create instances in the same region
as the image.

On apply, the provider downloads the release image on the machine running
Terraform, then uploads it to the project's image store. The machine needs
enough temporary disk for the image.

`image_version` defaults to the release the module is pinned to, so bumping
`ref` upgrades the image too. A new version replaces the image, and with it any
instance whose `image_id` isn't ignored as above. Instances are updated with
`nixos-rebuild` instead.

## Requirements

| Name | Version |
|---|---|
| terraform / opentofu | >= 1.3 |
| terraform-provider-openstack/openstack | >= 3.0, < 4.0 |

## Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `image_version` | Release tag to upload | `string` | the module's release |
| `name` | Image name | `string` | `nixos-<image_version>` |
| `tags` | Tags to apply to the image | `list(string)` | `[]` |

## Outputs

| Name | Description |
|---|---|
| `id` | ID of the image, for `openstack_compute_instance_v2.image_id` |
