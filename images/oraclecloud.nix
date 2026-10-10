{ modulesPath, ... }:
{
  # Provides the UEFI disk image builder plus Oracle Cloud integration: serial
  # consoles for both x86_64 and Arm (A1) shapes, and root SSH keys pulled from
  # the instance metadata service.
  imports = [ "${modulesPath}/virtualisation/oci-image.nix" ];
}
