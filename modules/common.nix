# Shared by every machine in this flake. Host-specific settings (hostname,
# hardware, printer drivers, OBS) belong in hosts/<name>/configuration.nix.
{ config, pkgs, ... }:

let
  # Pinned nixpkgs-unstable, exposed by the overlay in flake.nix.
  unstable = pkgs.unstable;
in
{
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable networking
  networking.networkmanager.enable = true;

  time.timeZone = "Asia/Kolkata";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_IN";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_IN";
    LC_IDENTIFICATION = "en_IN";
    LC_MEASUREMENT = "en_IN";
    LC_MONETARY = "en_IN";
    LC_NAME = "en_IN";
    LC_NUMERIC = "en_IN";
    LC_PAPER = "en_IN";
    LC_TELEPHONE = "en_IN";
    LC_TIME = "en_IN";
  };

  # Enable the X11 windowing system.
  # You can disable this if you're only using the Wayland session.
  services.xserver.enable = true;

  # Enable the KDE Plasma Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.tailscale = {
    # Enable tailscale at startup
    enable = true;

    # If you would like to use a preauthorized key, set
    # authKeyFile = "/run/secrets/tailscale_key";
    # Note: maximum expire time is 90 days
  };

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    # jack.enable = true;
  };

  fonts.packages = with pkgs; [
    iosevka
  ];

  users.users."romeus" = {
    isNormalUser = true;
    description = "Matheus Romeus";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      kdePackages.kate
    ];
  };

  # git needed some additional config so we keep it here globally instead of another dotfile
  programs.git = {
    enable = true;

    config = {
      user.name = "Kevin Roy";
      user.email = "57178348+kevnroy@users.noreply.github.com";

      init.defaultBranch = "main";
      pull.rebase = true;

      core.editor = "nvim";
    };
  };

  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    vim
    wget
    librewolf
    btop
    fastfetch
    curl
    vscodium
    obsidian
    ungoogled-chromium
    proton-vpn
    localsend
    kitty
    qbittorrent
    stow
    nodejs
    python3
    claude-code
    pi-coding-agent
    codex
    tmux
    ollama
    go
    tailscale

    unstable.opencode
    unstable.t3code
    unstable.zed-editor
    unstable.neovim
  ];

  # Wallpaper lives in the repo; switch it from the KDE picker or run
  # ./scripts/set-wallpaper.sh. Stable path so a rebuild never breaks it.
  environment.etc."swarm/wallpaper.jpg".source = ../wallpapers/maxresdefault2.jpg;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  system.stateVersion = "26.05"; # Did you read the comment?
}
