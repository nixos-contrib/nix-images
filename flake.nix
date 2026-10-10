{
  description = "Base NixOS images for cloud providers";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  outputs =
    { self, nixpkgs }:
    let
      inherit (nixpkgs) lib;

      # Every ./images/<variant>.nix becomes an image named after the variant.
      variants = map (lib.removeSuffix ".nix") (builtins.attrNames (builtins.readDir ./images));

      # Variants not listed here are built for x86_64-linux only.
      variantSystems = {
        oraclecloud = [
          "x86_64-linux"
          "aarch64-linux"
        ];
      };
      systemsOf = variant: variantSystems.${variant} or [ "x86_64-linux" ];
      systems = lib.unique (lib.concatMap systemsOf variants);

      mkSystem =
        variant: system:
        lib.nixosSystem {
          inherit system;
          modules = [
            ./configuration.nix
            ./images/${variant}.nix
            # Stable file name so the release asset URL is predictable.
            { image.baseName = "nixos-${variant}-${system}"; }
          ];
        };

      # The x86_64-linux configuration keeps the plain variant name; other
      # systems get a suffix, e.g. oraclecloud-aarch64-linux.
      configName = variant: system: if system == "x86_64-linux" then variant else "${variant}-${system}";
    in
    {
      nixosConfigurations = lib.listToAttrs (
        lib.concatMap (
          variant:
          map (system: lib.nameValuePair (configName variant system) (mkSystem variant system)) (
            systemsOf variant
          )
        ) variants
      );

      packages = lib.genAttrs systems (
        system:
        lib.genAttrs (lib.filter (variant: lib.elem system (systemsOf variant)) variants) (
          variant: self.nixosConfigurations.${configName variant system}.config.system.build.image
        )
      );
    };
}
