# nixos-image

Base NixOS image for DigitalOcean droplets, built by GitHub Actions and
published as a GitHub release asset.

## Releasing

Releases are managed by [release-please](https://github.com/googleapis/release-please)
from [Conventional Commits](https://www.conventionalcommits.org/). Every push to
`main` builds the image; release-please keeps a release PR open, and merging it
tags a release and attaches `nixos-digital-ocean-x86_64-linux.qcow2.gz` and
`SHA256SUMS` to it:

```
https://github.com/nixos-contrib/nixos-image/releases/download/<tag>/nixos-digital-ocean-x86_64-linux.qcow2.gz
```

nixpkgs is bumped weekly by an auto-merged `chore(flake)` PR; those commits
don't cut a release on their own.

## Building locally

Needs an `x86_64-linux` machine or remote builder:

```sh
nix build .#digital-ocean
```

## Customizing

Edit [configuration.nix](configuration.nix). The image imports nixpkgs'
`digital-ocean-image.nix` module, which configures networking, the hostname and
root SSH keys from the droplet metadata service and enables `do-agent`.

## Provisioning with Terraform

See [examples/terraform](examples/terraform/main.tf). DigitalOcean fetches the
image from the release URL, so the release asset has to be publicly
downloadable.

Once a droplet is running, manage it from the flake, for example:

```sh
nixos-rebuild switch --flake .#digital-ocean --target-host root@<ip>
```
