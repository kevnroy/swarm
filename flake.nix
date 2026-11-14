{
  description = "swarm - personal NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }:
    let
      # Every machine shares modules/common.nix and only differs in its
      # hostname and hardware-configuration.nix (disk UUIDs, CPU vendor).
      mkHost = hostname: nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./modules/common.nix
          ./hosts/${hostname}/configuration.nix
          ({ ... }: {
            # `pkgs.unstable.*` behaves like the old <nixos-unstable> channel,
            # but the revision is pinned by flake.lock instead of a root channel.
            nixpkgs.overlays = [
              (final: prev: {
                unstable = import nixpkgs-unstable {
                  system = prev.stdenv.hostPlatform.system;
                  config = prev.config;
                };
              })
            ];
          })
        ];
      };
    in {
      nixosConfigurations = {
        desktop = mkHost "desktop";
        laptop = mkHost "laptop";
      };
    };
}
