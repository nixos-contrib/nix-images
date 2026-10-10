{
  description = "Base NixOS image for DigitalOcean droplets";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { self, nixpkgs }:
    let
      system = "x86_64-linux";
      forAllSystems = nixpkgs.lib.genAttrs [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    in
    {
      nixosConfigurations.digitalocean = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [ ./configuration.nix ];
      };

      packages.${system} = {
        digitalocean = self.nixosConfigurations.digitalocean.config.system.build.digitalOceanImage;
        default = self.packages.${system}.digitalocean;
      };

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            name = "nixos-image";
            packages = with pkgs; [
              actionlint
              opentofu
            ];
          };
        }
      );
    };
}
