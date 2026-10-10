{
  description = "Base NixOS images for cloud providers";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;
      system = "x86_64-linux";

      # Every ./images/<variant>.nix becomes an image named after the variant.
      variants = map (lib.removeSuffix ".nix") (builtins.attrNames (builtins.readDir ./images));
    in
    {
      nixosConfigurations = lib.genAttrs variants (
        variant:
        lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
            ./images/${variant}.nix
            # Stable file name so the release asset URL is predictable.
            { image.baseName = "nixos-${variant}-${system}"; }
          ];
        }
      );

      packages.${system} = lib.genAttrs variants (
        variant: self.nixosConfigurations.${variant}.config.system.build.image
      );
    };
}
