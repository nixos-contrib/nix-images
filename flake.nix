{
  description = "Base NixOS image for DigitalOcean droplets";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.digital-ocean = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./configuration.nix ];
      };
      packages.${system} = {
        digital-ocean = self.nixosConfigurations.digital-ocean.config.system.build.digitalOceanImage;
        default = self.packages.${system}.digital-ocean;
      };
    };
}
