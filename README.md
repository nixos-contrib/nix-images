# nix-images

[![CI](https://github.com/nixos-contrib/nix-images/actions/workflows/ci.yml/badge.svg)](https://github.com/nixos-contrib/nix-images/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/nixos-contrib/nix-images)](https://github.com/nixos-contrib/nix-images/releases/latest)
[![NixOS 26.05](https://img.shields.io/badge/NixOS-26.05-5277C3?logo=nixos&logoColor=white)](https://nixos.org)
[![DigitalOcean](https://img.shields.io/badge/DigitalOcean-custom%20image-0080FF?logo=digitalocean&logoColor=white)](deployment/terraform/modules/digitalocean)

Run NixOS on DigitalOcean without `nixos-infect`. Every release ships a
prebuilt NixOS image, plus a Terraform module that turns it into a droplet.

## Quick start

```hcl
module "digitalocean_nixos_image" {
  source = "github.com/nixos-contrib/nix-images//deployment/terraform/modules/digitalocean?ref=v0.1.0"

  regions = ["fra1"]
}

resource "digitalocean_droplet" "nixos" {
  name     = "nixos"
  image    = module.digitalocean_nixos_image.image_id
  region   = "fra1"
  size     = "s-1vcpu-1gb"
  ssh_keys = [var.ssh_key_fingerprint]
}
```

Run `terraform apply` (or `tofu apply`), then `ssh root@<ip>`. Your SSH key is
installed from the droplet metadata. From there, manage the droplet with
`nixos-rebuild`:

```sh
nixos-rebuild switch --flake .#digitalocean --target-host root@<ip>
```

See the [module docs](deployment/terraform/modules/digitalocean) and the
[complete example](deployment/terraform/modules/digitalocean/examples/basic).

## Download

Not using Terraform? Upload the image through the DigitalOcean control panel or
API, using its release URL:

```
https://github.com/nixos-contrib/nix-images/releases/download/<tag>/nixos-digitalocean-x86_64-linux.qcow2.gz
```

Each release also has a `SHA256SUMS` file for checking the download.

## What's in the image

- NixOS 26.05 with flakes enabled, plus `git` and `vim`
  ([configuration.nix](configuration.nix))
- Networking, hostname and root SSH keys configured from the DigitalOcean
  metadata service
- SSH with password login disabled, and the DigitalOcean monitoring agent
  (`do-agent`)

## Customizing

Fork the repository and edit [configuration.nix](configuration.nix), which every
image shares. Each file in [images](images) is a variant that imports the
matching nixpkgs image module. For example,
[images/digitalocean.nix](images/digitalocean.nix) imports
`digital-ocean-image.nix`.

To add a provider, create `images/<variant>.nix` importing one of the modules
listed in nixpkgs'
[images.nix](https://github.com/NixOS/nixpkgs/blob/nixos-26.05/nixos/modules/image/images.nix).
It builds as `.#<variant>` and ships in every release as
`nixos-<variant>-x86_64-linux.*`.

To build locally, you need an `x86_64-linux` machine or remote builder:

```sh
nix build .#digitalocean
```

## Releasing

Releases are managed by [release-please](https://github.com/googleapis/release-please)
from [Conventional Commits](https://www.conventionalcommits.org/). Every push to
`main` builds the images, and release-please keeps a release PR open. Merging
that PR tags a release and attaches every image and `SHA256SUMS` to it.

A weekly `chore(flake)` PR updates nixpkgs and merges automatically. These
updates don't trigger a release by themselves.
