{
  imports = [
    ./hardware-configuration.nix
  ];

  # Distinct per host: Tailscale keys machines by hostname, so a duplicate
  # name will clash in the tailnet.
  networking.hostName = "laptop";

  # This machine is a 4 GB i3-7020U, so it inherits only the shared baseline
  # from modules/common.nix. Add laptop-only packages here if you want them.
}
