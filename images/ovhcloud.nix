{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}:
{
  # OVHcloud Public Cloud runs OpenStack. openstack-config.nix pulls root SSH
  # keys and the hostname from the metadata service and provides the virtio
  # drivers and serial console; disk-image.nix provides the disk image
  # builder.
  imports = [
    "${modulesPath}/virtualisation/disk-image.nix"
    "${modulesPath}/virtualisation/openstack-config.nix"
  ];

  # Public Cloud instances are x86_64 and boot with BIOS.
  image.efiSupport = false;

  # OVHcloud recommends the QEMU guest agent, which the module's
  # hw_qemu_guest_agent image property asks the hypervisor to use. It enables
  # live snapshots.
  services.qemuGuest.enable = true;

  # The uncompressed qcow2 is over GitHub's 2 GiB release asset limit.
  # Compressed qcow2 is still plain qcow2, so Glance accepts it as-is.
  system.build.image = lib.mkForce (
    import "${modulesPath}/../lib/make-disk-image.nix" {
      inherit config lib pkgs;
      inherit (config.virtualisation) diskSize;
      inherit (config.image) baseName;
      format = "qcow2-compressed";
      partitionTableType = "legacy";
    }
  );
}
