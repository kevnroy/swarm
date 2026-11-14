{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Distinct per host: Tailscale keys machines by hostname, so a duplicate
  # name will clash in the tailnet.
  networking.hostName = "nixos";

  # The printer lives at the desk; the laptop doesn't need its driver.
  # epson-202101w only exists in nixpkgs-unstable, not in the 26.05 release,
  # so it must come from pkgs.unstable (the original `with pkgs;` failed eval).
  services.printing.drivers = [
    pkgs.unstable.epson-202101w
  ];

  # OBS + virtual camera (droidcam) is desktop-only.
  programs.obs-studio = {
    enable = true;
    plugins = [ pkgs.obs-studio-plugins.droidcam-obs ];
    enableVirtualCamera = true;
  };

  boot.extraModprobeConfig = pkgs.lib.mkForce ''
    options v4l2loopback devices=1 video_nr=10 card_label="OBS Cam" exclusive_caps=1
  '';
}
