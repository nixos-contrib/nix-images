{ modulesPath, pkgs, ... }:
{
  # Provides the disk image builder plus DigitalOcean integration: networking,
  # hostname and root SSH keys are pulled from the droplet metadata service.
  imports = [ "${modulesPath}/virtualisation/digital-ocean-image.nix" ];

  # Stable file name so the release asset URL is predictable.
  image.baseName = "nixos-digitalocean-${pkgs.stdenv.hostPlatform.system}";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  environment.systemPackages = with pkgs; [
    git
    vim
  ];

  system.stateVersion = "26.05";
}
