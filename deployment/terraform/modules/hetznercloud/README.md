# hetznercloud

Uploads the NixOS Hetzner Cloud image from a release of this repository as a
snapshot. Servers are left to the caller; see [examples/basic](examples/basic)
for a complete setup on an Arm (CAX) server.

```hcl
module "hetznercloud_nixos_image" {
  source = "github.com/nixos-contrib/nix-images//deployment/terraform/modules/hetznercloud?ref=v0.1.0"

  system = "aarch64-linux"
}

resource "hcloud_server" "nixos" {
  image       = module.hetznercloud_nixos_image.id
  server_type = "cax11"
  ssh_keys    = [hcloud_ssh_key.this.id]
  # ...

  lifecycle {
    ignore_changes = [image]
  }
}
```

Hetzner can't import images directly. The
[imager](https://registry.terraform.io/providers/hcloud-talos/imager) provider
creates a temporary server in rescue mode, writes the release image to its
disk, snapshots it and deletes the server. An upload takes a few minutes and
bills the temporary server for that time. The provider reads the API token from
`HCLOUD_TOKEN`, like the `hcloud` provider.

`system` must match the server type's architecture: `aarch64-linux` for Arm
(CAX) servers, `x86_64-linux` for x86 (CX, CPX, CCX) servers. Hetzner refuses
to create a server from a snapshot of the other architecture.

`image_version` defaults to the release the module is pinned to, so bumping
`ref` upgrades the image too. A new version replaces the snapshot, and with it
any server whose `image` isn't ignored as above. Servers are updated with
`nixos-rebuild` instead.

## Requirements

| Name | Version |
|---|---|
| terraform / opentofu | >= 1.3 |
| hcloud-talos/imager | >= 1.0, < 2.0 |

## Inputs

| Name | Description | Type | Default |
|---|---|---|---|
| `system` | `aarch64-linux` or `x86_64-linux`, matching the server type | `string` | required |
| `image_version` | Release tag to upload | `string` | the module's release |
| `name` | Snapshot description | `string` | `nixos-<image_version>-<system>` |
| `location` | Location of the temporary upload server | `string` | `fsn1` |
| `labels` | Labels to apply to the snapshot, besides `os`, `creator` and `version` | `map(string)` | `{}` |

## Outputs

| Name | Description |
|---|---|
| `id` | ID of the snapshot image, for `hcloud_server.image` |
