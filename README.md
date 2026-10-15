# nix-images

[![CI](https://github.com/nixos-contrib/nix-images/actions/workflows/ci.yml/badge.svg)](https://github.com/nixos-contrib/nix-images/actions/workflows/ci.yml)
[![Release](https://img.shields.io/github/v/release/nixos-contrib/nix-images)](https://github.com/nixos-contrib/nix-images/releases/latest)
[![NixOS 26.05](https://img.shields.io/badge/NixOS-26.05-5277C3?logo=nixos&logoColor=white)](https://nixos.org)
[![DigitalOcean](https://img.shields.io/badge/DigitalOcean-custom%20image-0080FF?logo=digitalocean&logoColor=white)](deployment/terraform/modules/digitalocean)
[![Hetzner Cloud](https://img.shields.io/badge/Hetzner%20Cloud-x86__64%20%7C%20Arm-D50C2D?logo=hetzner&logoColor=white)](deployment/terraform/modules/hetznercloud)
[![Oracle Cloud](https://img.shields.io/badge/Oracle%20Cloud-x86__64%20%7C%20Arm-C74634?logo=oracle&logoColor=white)](deployment/terraform/modules/oraclecloud)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

Run NixOS on DigitalOcean, Hetzner Cloud and Oracle Cloud without
`nixos-infect`. Every release ships prebuilt NixOS images, plus Terraform
modules that import them as custom images.

> [!WARNING]
> This project is a work in progress and has not been tested yet. Images and
> Terraform modules may be broken, and interfaces may change without notice.
> Don't use it for anything you can't afford to lose.

## Quick start

```hcl
module "digitalocean_nixos_image" {
  source = "github.com/nixos-contrib/nix-images//deployment/terraform/modules/digitalocean?ref=v0.1.0"

  regions = ["fra1"]
}

resource "digitalocean_droplet" "nixos" {
  name     = "nixos"
  image    = module.digitalocean_nixos_image.id
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

## Hetzner Cloud

Hetzner images are built for both `x86_64-linux` and `aarch64-linux`, so they
run on the x86 (CX, CPX, CCX) and Arm (CAX) server types. Hetzner can't import
images directly, so the
[hetznercloud module](deployment/terraform/modules/hetznercloud) writes the
image to a temporary server and saves it as a snapshot:

```hcl
module "hetznercloud_nixos_image" {
  source = "github.com/nixos-contrib/nix-images//deployment/terraform/modules/hetznercloud?ref=v0.1.0"

  system = "aarch64-linux"
}
```

Use `module.hetznercloud_nixos_image.id` as the server's `image`; see the
[complete example](deployment/terraform/modules/hetznercloud/examples/basic),
which creates a CAX11 server. To upload by hand instead, use
[hcloud-upload-image](https://github.com/apricote/hcloud-upload-image) with the
release URL:

```sh
export HCLOUD_TOKEN=...
hcloud-upload-image upload \
  --image-url https://github.com/nixos-contrib/nix-images/releases/download/<tag>/nixos-hetznercloud-aarch64-linux.raw.xz \
  --compression xz \
  --architecture arm \
  --labels os=nixos
```

For the x86 image, use `nixos-hetznercloud-x86_64-linux.raw.xz` with
`--architecture x86`. Then create a server from the snapshot with your SSH key:

```sh
hcloud server create --name nixos --type cax11 --image <snapshot-id> --ssh-key <key>
```

The image installs your SSH key for root, and sets the hostname and network
config (including IPv6) from the server metadata with cloud-init. The root
partition grows to fill the disk on first boot. On a CAX server, manage the
system with:

```sh
nixos-rebuild switch --flake .#hetznercloud-aarch64-linux --target-host root@<ip>
```

Use `.#hetznercloud` for the x86_64 image.

## Oracle Cloud

Oracle images are built for both `x86_64-linux` and `aarch64-linux`, so they
run on the Always Free Ampere A1 (Arm) and E2.1.Micro (AMD) shapes. The
[oraclecloud module](deployment/terraform/modules/oraclecloud) uploads and
imports the image for you:

```hcl
module "oraclecloud_nixos_image" {
  source = "github.com/nixos-contrib/nix-images//deployment/terraform/modules/oraclecloud?ref=v0.1.0"

  compartment_id = var.compartment_id
  bucket         = "nixos-images"
  system         = "aarch64-linux"
}
```

Use `module.oraclecloud_nixos_image.id` as the instance's `source_id`; see the
[complete example](deployment/terraform/modules/oraclecloud/examples/basic),
which creates the network and an A1 instance. To import by hand instead, use
the release URL:

```
https://github.com/nixos-contrib/nix-images/releases/download/<tag>/nixos-oraclecloud-aarch64-linux.qcow2
https://github.com/nixos-contrib/nix-images/releases/download/<tag>/nixos-oraclecloud-x86_64-linux.qcow2
```

1. Upload the `.qcow2` to an Object Storage bucket.
2. Under **Compute → Custom Images**, import it from the bucket with image type
   **QCOW2** and launch mode **Paravirtualized mode**.
3. For the Arm image, open the imported image and use **Edit details** to add
   `VM.Standard.A1.Flex` to its compatible shapes.
4. Create an instance from the image with your SSH key, then `ssh root@<ip>`.

The image boots with UEFI, gets its network config over DHCP, and installs your
SSH key from the instance metadata. The root partition grows to fill the boot
volume on first boot. On an A1 instance, manage the system with:

```sh
nixos-rebuild switch --flake .#oraclecloud-aarch64-linux --target-host root@<ip>
```

Use `.#oraclecloud` for the x86_64 image.

## What's in the images

- NixOS 26.05 with flakes enabled, plus `git` and `vim`
  ([configuration.nix](configuration.nix))
- DigitalOcean: networking, hostname and root SSH keys configured from the
  droplet metadata service. SSH with password login disabled, and the
  DigitalOcean monitoring agent (`do-agent`)
- Hetzner Cloud: BIOS boot on x86 and UEFI boot on Arm, with root SSH keys,
  hostname and network config applied by cloud-init. SSH with password login
  disabled
- Oracle Cloud: UEFI boot, serial console, NTP from the Oracle time service,
  and root SSH keys fetched from the instance metadata service

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
`nixos-<variant>-x86_64-linux.*`. To also build it for Arm, add it to
`variantSystems` in [flake.nix](flake.nix). Its `aarch64-linux` image is then
`.#packages.aarch64-linux.<variant>`, with the NixOS configuration
`.#<variant>-aarch64-linux`.

To build locally, you need a Linux machine or remote builder for the target
system:

```sh
nix build .#digitalocean
nix build .#packages.aarch64-linux.oraclecloud
nix build .#packages.aarch64-linux.hetznercloud
```

## Releasing

Releases are managed by [release-please](https://github.com/googleapis/release-please)
from [Conventional Commits](https://www.conventionalcommits.org/). Every push to
`main` builds the images, and release-please keeps a release PR open. Merging
that PR tags a release and attaches every image and `SHA256SUMS` to it.

A weekly `chore(flake)` PR updates nixpkgs and merges automatically. These
updates don't trigger a release by themselves.
