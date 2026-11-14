# PLACEHOLDER - replace this file with the real one generated on the laptop.
#
#   sudo nixos-generate-config --dir /tmp/hw
#   cp /tmp/hw/hardware-configuration.nix <repo>/hosts/laptop/
#
# It must be generated on the laptop itself: it contains that machine's disk
# UUIDs and btrfs subvolumes. The desktop's copy has different UUIDs and
# kvm-intel, so copying it over would produce an unbootable system.
throw ''
  hosts/laptop/hardware-configuration.nix is still the placeholder.

  Generate it on the laptop, then copy it in:

    sudo nixos-generate-config --dir /tmp/hw
    cp /tmp/hw/hardware-configuration.nix <repo>/hosts/laptop/

  Then rebuild with:

    sudo nixos-rebuild switch --flake <repo>#laptop
''
