{ modulesPath, ... }:
{
  # Provides the disk image builder plus DigitalOcean integration: networking,
  # hostname and root SSH keys are pulled from the droplet metadata service.
  imports = [ "${modulesPath}/virtualisation/digital-ocean-image.nix" ];
}
