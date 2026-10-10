# nixos-image

Base NixOS images for cloud providers, built by GitHub Actions and published
as GitHub release assets. Currently: DigitalOcean.

## Releasing

Releases are managed by [release-please](https://github.com/googleapis/release-please)
from [Conventional Commits](https://www.conventionalcommits.org/). Every push to
`main` builds the images; release-please keeps a release PR open, and merging
it tags a release and attaches every image plus `SHA256SUMS` to it:

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

[configuration.nix](configuration.nix) is shared by every image. Each file in
[images](images) is a variant that imports the matching nixpkgs image module,
e.g. [images/digital-ocean.nix](images/digital-ocean.nix) uses
`digital-ocean-image.nix`, which configures networking, the hostname and root
SSH keys from the droplet metadata service and enables `do-agent`.

To add a provider, create `images/<variant>.nix` importing one of the modules
listed in nixpkgs'
[images.nix](https://github.com/NixOS/nixpkgs/blob/nixos-26.05/nixos/modules/image/images.nix).
It's picked up as `.#<variant>` and released as `nixos-<variant>-x86_64-linux.*`.

## Provisioning with Terraform

See [examples/terraform](examples/terraform/main.tf). DigitalOcean fetches the
image from the release URL, so the release asset has to be publicly
downloadable.

Once a droplet is running, manage it from the flake, for example:

```sh
nixos-rebuild switch --flake .#digital-ocean --target-host root@<ip>
```
