{
  description = "swarm - personal NixOS configuration";

  inputs = {
    # Pinned to revisions already present in both machines' stores, so a
    # rebuild doesn't re-download the world:
    #   26.05.12400.da6dc0e7b260  = laptop's current system
    #   26.11pre1106360.0bb2eedc  = desktop's current system (unstable)
    # Bump deliberately with `nix flake update`, not on every rebuild.
    nixpkgs.url = "github:NixOS/nixpkgs/da6dc0e7b26060f2f71ce3ef7088fb56ee44fa36";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/0bb2eedc20e4739f29e8045034f2828ad7054f8f";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, ... }:
    let
      # Every machine shares modules/common.nix and only differs in its
      # hostname, hardware-configuration.nix and which pinned nixpkgs it uses
      # as its base. `base` is the rev that machine already runs, so a rebuild
      # reuses its store instead of re-downloading a closure.
      mkHost = { hostname, base }: base.lib.nixosSystem {
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
        # 26.11pre1106360.0bb2eedc - the desktop's current system.
        desktop = mkHost { hostname = "desktop"; base = nixpkgs-unstable; };
        # 26.05.12400.da6dc0e7 - the laptop's current system.
        laptop = mkHost { hostname = "laptop"; base = nixpkgs; };
      };
    };
}
