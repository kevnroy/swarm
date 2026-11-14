# NixOS config: desktop + laptop

Personal NixOS configuration, shared between two machines with
[`flake.nix`](flake.nix).

```
flake.nix                     # pins nixpkgs + nixpkgs-unstable, defines both hosts
modules/common.nix            # lean baseline both machines share
hosts/desktop/
  configuration.nix           # hostname, printer, OBS, heavy GUI/media apps
  hardware-configuration.nix  # disk UUIDs + CPU vendor for THIS machine
hosts/laptop/
  configuration.nix           # hostname only (4 GB i3: no heavy apps)
  hardware-configuration.nix  # generated on the laptop itself
wallpapers/maxresdefault2.jpg # installed to /etc/swarm/wallpaper.jpg
kitty/.config/kitty/         # terminal config, symlinked by hand (stow)
scripts/set-wallpaper.sh      # applies the wallpaper in KDE Plasma
```

## Pinning

`flake.nix` pins two exact revisions, chosen because they are already in both
machines' stores:

| input | revision | matches |
|---|---|---|
| `nixpkgs` | `da6dc0e7` | `26.05.12400` — the laptop's system |
| `nixpkgs-unstable` | `0bb2eedc` | `26.11pre1106360` — the desktop's system |

That keeps `nixos-rebuild` cheap: nothing is re-downloaded, only the delta
between the two configs moves. Bump deliberately with `nix flake update`, then
rebuild both machines in one go. Pinning to a *newer* rev costs a full ~15 GB
closure download on both sides.

## Rebuild

```sh
sudo nixos-rebuild switch --flake ~/personal/swarm#desktop   # this machine
sudo nixos-rebuild switch --flake ~/personal/swarm#laptop    # on the laptop
nix flake update                                             # bump pins
```

If the hostname matches the flake attribute, `nixos-rebuild switch --flake .`
picks it automatically.

## Deploying over Tailscale

The laptop is reachable on the tailnet (`100.92.14.124`, node name `nixos-1`
until the hostname change lands) with Tailscale SSH enabled:

```sh
sudo tailscale set --ssh          # once, on the laptop

nixos-rebuild switch --flake ~/personal/swarm#laptop \
  --target-host root@100.92.14.124
```

The build happens locally and the closure is copied to the target. Use `--sudo`
instead of `root@` if you'd rather deploy as `romeus`. Tailscale SSH applies the
tailnet ACL, which may ask for a browser check on first connection.

## Setting up another machine

1. Install NixOS as usual. It writes its own `/etc/nixos/configuration.nix`.
2. Clone this repo and generate the hardware file **on that machine**:

   ```sh
   git clone git@github.com:kevnroy/swarm.git ~/personal/swarm
   sudo nixos-generate-config --dir /tmp/hw
   cp /tmp/hw/hardware-configuration.nix ~/personal/swarm/hosts/<name>/
   ```

   Never copy another host's `hardware-configuration.nix` — the disk UUIDs and
   filesystem types are per machine (the desktop is btrfs with subvolumes, the
   laptop is plain ext4).

3. Rebuild:

   ```sh
   sudo nixos-rebuild switch --flake ~/personal/swarm#<name>
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
  (Tailscale needs unique names), printer drivers, OBS, heavy GUI apps.
- Everything else belongs in `modules/common.nix`.
- `pkgs.unstable.*` comes from the pinned `nixpkgs-unstable` flake input, so no
  `nixos-unstable` channel is required on either machine.
