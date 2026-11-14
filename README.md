# NixOS config: desktop + laptop

Personal NixOS configuration, shared between two machines with
[`flake.nix`](flake.nix).

```
flake.nix                     # pins nixpkgs + nixpkgs-unstable, defines both hosts
modules/common.nix            # everything both machines share
hosts/desktop/
  configuration.nix           # hostname, printer, OBS
  hardware-configuration.nix  # disk UUIDs + CPU vendor for THIS machine
hosts/laptop/
  configuration.nix           # hostname only, so far
  hardware-configuration.nix  # placeholder until generated on the laptop
wallpapers/maxresdefault2.jpg # installed to /etc/swarm/wallpaper.jpg
kitty/.config/kitty/         # terminal config, symlinked by hand (stow)
scripts/set-wallpaper.sh      # applies the wallpaper in KDE Plasma
```

## Rebuild

```sh
sudo nixos-rebuild switch --flake ~/personal/swarm#desktop   # this machine
nix flake update                                             # bump pins
```

Use `--flake .#laptop` on the laptop. If the hostname matches the flake
attribute, `nixos-rebuild switch --flake .` picks it automatically.

## Setting up the laptop

1. Install NixOS as usual. It writes its own `/etc/nixos/configuration.nix`.
2. Clone this repo and generate the laptop's hardware file on the laptop:

   ```sh
   git clone git@github.com:kevnroy/swarm.git ~/personal/swarm
   sudo nixos-generate-config --dir /tmp/hw
   cp /tmp/hw/hardware-configuration.nix ~/personal/swarm/hosts/laptop/
   ```

   Never copy `hosts/desktop/hardware-configuration.nix` — it has the
   desktop's disk UUIDs and would not boot.

3. Rebuild:

   ```sh
   sudo nixos-rebuild switch --flake ~/personal/swarm#laptop
   ```

4. Wallpaper:

   ```sh
   ~/personal/swarm/scripts/set-wallpaper.sh
   ```

5. `system.stateVersion` stays `26.05` in `modules/common.nix` unless a machine
   was installed with an older release, in which case keep that machine's
   original value — it is not a version to bump.

## Notes

- Machine-specific: `hosts/*/hardware-configuration.nix`, `networking.hostName`
  (Tailscale needs unique names), printer drivers, OBS.
- Everything else belongs in `modules/common.nix`.
- `pkgs.unstable.*` comes from the pinned `nixpkgs-unstable` flake input, so no
  `nixos-unstable` channel is required on either machine.
