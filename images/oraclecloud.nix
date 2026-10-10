{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}:
let
  inherit (config.image) filePath;
in
{
  # Provides the UEFI disk image builder plus Oracle Cloud integration: serial
  # consoles for both x86_64 and Arm (A1) shapes, and root SSH keys pulled from
  # the instance metadata service.
  imports = [ "${modulesPath}/virtualisation/oci-image.nix" ];

  # The uncompressed qcow2 is over GitHub's 2 GiB release asset limit.
  # Compressed qcow2 is still plain qcow2, so Oracle imports it as-is.
  system.build.image = lib.mkForce (
    pkgs.runCommand "oci-image-compressed" { nativeBuildInputs = [ pkgs.qemu-utils ]; } ''
      mkdir $out
      qemu-img convert -c -f qcow2 -O qcow2 ${config.system.build.OCIImage}/${filePath} $out/${filePath}
    ''
  );
}
