{
  imports = [
    ./hardware-configuration.nix
  ];

  # Distinct per host: Tailscale keys machines by hostname, so a duplicate
  # name will clash in the tailnet.
  networking.hostName = "laptop";

  # Add laptop-only settings here (e.g. services.printing.drivers for a local
  # printer, extra kernel modules, a different timezone for travel).
  # Everything shared with the desktop lives in modules/common.nix.
}
