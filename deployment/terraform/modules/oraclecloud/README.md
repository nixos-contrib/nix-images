# oraclecloud

Imports the NixOS Oracle Cloud image from a release of this repository as a
custom image, and marks it compatible with the Always Free shape for its
architecture. Instances are left to the caller; see
[examples/basic](examples/basic) for a complete setup on an Ampere A1 shape.

```hcl
module "oraclecloud_nixos_image" {
  source = "github.com/nixos-contrib/nix-images//deployment/terraform/modules/oraclecloud?ref=v0.1.0"

  compartment_id = var.compartment_id
  bucket         = "nixos-images"
  system         = "aarch64-linux"
}

resource "oci_core_instance" "nixos" {
  shape = "VM.Standard.A1.Flex"

  source_details {
    source_type = "image"
    source_id   = module.oraclecloud_nixos_image.id
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
  # ...

  lifecycle {
    ignore_changes = [source_details[0].source_id]
  }
}
```

Oracle only imports images from Object Storage. On apply, the module creates a
write-only pre-authenticated request for one object in `bucket`, then uses
`curl` to download the release image and upload it there. The machine running
Terraform needs `curl`, a POSIX shell and enough temporary disk for the image.
The OCI CLI isn't needed.

The uploaded object isn't managed by Terraform and stays in the bucket after
the image is imported. You can delete it once the image exists; empty the
bucket before destroying it.

`image_version` defaults to the release the module is pinned to, so bumping
`ref` upgrades the image too. A new version replaces the custom image, and with
it any instance whose `source_id` isn't ignored as above. Instances are updated
with `nixos-rebuild` instead.

## Requirements

| Name | Version |
|---|---|
| terraform / opentofu | >= 1.4 |
| oracle/oci | >= 6.0, < 10.0 |
| curl | any |

## Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `compartment_id` | Compartment to create the image in | `string` | required |
| `bucket` | Existing bucket to upload the image to | `string` | required |
| `system` | `aarch64-linux` or `x86_64-linux` | `string` | `aarch64-linux` |
| `image_version` | Release tag to upload | `string` | the module's release |
| `name` | Image display name | `string` | `nixos-<image_version>-<system>` |
| `shapes` | Shapes to mark the image compatible with | `list(string)` | `VM.Standard.A1.Flex` or `VM.Standard.E2.1.Micro` |
| `freeform_tags` | Free-form tags to apply to the image | `map(string)` | `{}` |

## Outputs

| Name | Description |
|---|---|
| `id` | OCID of the custom image, for `oci_core_instance.source_details.source_id` |
