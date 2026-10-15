{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}:
{
  # Provides the raw disk image builder; qemu-guest adds the virtio drivers
  # Hetzner's virtual disks and NICs need in the initrd.
  imports = [
    "${modulesPath}/virtualisation/disk-image.nix"
    "${modulesPath}/profiles/qemu-guest.nix"
  ];

  # Hetzner boots x86 servers with BIOS and Arm (CAX) servers with UEFI only.
  # Hetzner can't import images directly; hcloud-upload-image writes the raw
  # image to a server's disk and snapshots it.
  image.format = "raw";
  image.efiSupport = pkgs.stdenv.hostPlatform.isAarch64;
  boot.loader.grub.devices = lib.mkIf (!config.image.efiSupport) [ "/dev/sda" ];

  # Root SSH keys, hostname and network config (including the server's static
  # IPv6 address) come from the Hetzner metadata service.
  services.cloud-init = {
    enable = true;
    network.enable = true;
  };
  networking.useNetworkd = true;
  networking.hostName = lib.mkDefault "";

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # Keeps the release asset small; hcloud-upload-image decompresses it with
  # --compression zstd.
  image.extension = lib.mkForce "img.zst";
  system.build.image = lib.mkForce (
    import "${modulesPath}/../lib/make-disk-image.nix" {
      inherit config lib pkgs;
      inherit (config.virtualisation) diskSize;
      inherit (config.image) baseName format;
      partitionTableType = if config.image.efiSupport then "efi" else "legacy";
      postVM = "${pkgs.zstd}/bin/zstd -T0 --rm $diskImage";
    }
  );
}
