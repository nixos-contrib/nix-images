# digitalocean

Uploads the NixOS DigitalOcean image from a release of this repository as a
custom image. Droplets are left to the caller; see
[examples/basic](examples/basic) for a complete setup.

```hcl
module "digitalocean_nixos_image" {
  source = "github.com/nixos-contrib/nix-images//deployment/terraform/modules/digitalocean?ref=v0.1.0"

  regions = ["fra1"]
}

resource "digitalocean_droplet" "nixos" {
  image = module.digitalocean_nixos_image.image_id
  # ...

  lifecycle {
    ignore_changes = [image]
  }
}
```

`image_version` defaults to the release the module is pinned to, so bumping
`ref` upgrades the image too. A new version replaces the custom image, and with
it any droplet whose `image` isn't ignored as above. Droplets are updated with
`nixos-rebuild` instead.

## Requirements

| Name | Version |
|---|---|
| terraform / opentofu | >= 1.3 |
| digitalocean/digitalocean | >= 2.0, < 3.0 |

## Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `regions` | Regions to make the image available in | `list(string)` | required |
| `image_version` | Release tag to upload | `string` | the module's release |
| `name` | Image name | `string` | `nixos-<image_version>` |
| `tags` | Tags to apply to the image | `list(string)` | `[]` |

## Outputs

| Name | Description |
|---|---|
| `image_id` | ID of the custom image, for `digitalocean_droplet.image` |
