# digital-ocean

Uploads the NixOS DigitalOcean image from a release of this repository as a
custom image. Droplets are left to the caller.

```hcl
module "nixos_image" {
  source  = "github.com/nixos-contrib/nix-images//deployment/terraform/modules/digital-ocean?ref=v0.1.0"
  regions = ["fra1"]
}

resource "digitalocean_droplet" "nixos" {
  name   = "nixos"
  image  = module.nixos_image.id
  region = "fra1"
  size   = "s-1vcpu-1gb"

  # Required for custom images; the image installs these keys for root.
  ssh_keys = [var.ssh_key_fingerprint]

  # The droplet is updated with nixos-rebuild from then on; don't recreate it
  # when a newer image is released.
  lifecycle {
    ignore_changes = [image]
  }
}
```

`image_version` defaults to the release the module is pinned to, so bumping
`ref` upgrades the image too. A new version replaces the custom image, and with
it any droplet whose `image` isn't ignored as above.

| Variable | Description | Default |
|---|---|---|
| `regions` | Regions to make the image available in | required |
| `image_version` | Release tag to upload | the module's release |
| `name` | Image name | `nixos-<image_version>` |
| `tags` | Image tags | `[]` |

| Output | Description |
|---|---|
| `id` | Image ID for `digitalocean_droplet.image` |
