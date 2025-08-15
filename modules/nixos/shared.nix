# ============================================================================
# SHARED NIXOS CONFIGURATION
# ============================================================================

{
  pkgs,
  inputs,
  ...
}:
{
  # ========================================================================
  # MODULE IMPORTS
  # ========================================================================

  imports = [
    inputs.home-manager.nixosModules.default
    ./nvidia.nix
    ./sway.nix
    ./virtualisation.nix
    ./android-emulator.nix
    ./rust.nix
  ];

  # ========================================================================
  # BOOT CONFIGURATION
  # ========================================================================

  boot.loader = {
    efi = {
      canTouchEfiVariables = true;
    };
    grub = {
      enable = true;
      efiSupport = true;
      device = "nodev";
      useOSProber = true;
    };
  };

  boot.kernelPackages = pkgs.linuxPackages_latest;
  hardware.enableRedistributableFirmware = true;

  # ========================================================================
  # NIX CONFIGURATION
  # ========================================================================

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # ========================================================================
  # NETWORKING CONFIGURATION
  # ========================================================================

  networking.networkmanager.enable = true;

  # ========================================================================
  # LOCALIZATION
  # ========================================================================

  time.timeZone = "Europe/Paris";

  # ========================================================================
  # CORE SYSTEM SERVICES
  # ========================================================================

  services = {
    openssh.enable = true;
    xserver.enable = false;
    gnome.gnome-keyring.enable = true;
  };

  # ========================================================================
  # WAYLAND SESSION CONFIGURATION
  # ========================================================================

  environment.etc."wayland-sessions/sway.desktop".text = ''
    [Desktop Entry]
    Name=Sway
    Comment=An i3-compatible Wayland compositor
    Exec=sway --unsupported-gpu
    Type=Application
    Keywords=tiling;wm;windowmanager;wayland;compositor;
  '';

  # ========================================================================
  # TYPOGRAPHY CONFIGURATION
  # ========================================================================

  fonts = {
    packages = with pkgs; [
      fira
      nerd-fonts.fira-code
    ];

    fontconfig.defaultFonts = {
      serif = [ "Fira Sans" ];
      sansSerif = [ "Fira Sans" ];
      monospace = [ "Fira Code Nerd Font" ];
    };
  };

  # ========================================================================
  # USER ACCOUNT CONFIGURATION
  # ========================================================================

  users.users.ebaron = {
    isNormalUser = true;
    extraGroups = [
      "wheel"
      "fuse"
      "docker"
    ];

    packages = with pkgs; [
      tree
      btop
    ];
  };

  # ========================================================================
  # HOME MANAGER CONFIGURATION
  # ========================================================================

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
  };

  # ========================================================================
  # SYSTEM PACKAGES
  # ========================================================================

  environment.systemPackages = with pkgs; [
    wget
    grim
    slurp
    wl-clipboard
    mako
    xdg-utils
    neovim
  ];

  # ========================================================================
  # SYSTEM VERSION
  # ========================================================================

  system.stateVersion = "25.05";
}
