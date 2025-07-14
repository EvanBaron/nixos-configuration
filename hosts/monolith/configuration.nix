{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    inputs.home-manager.nixosModules.default
    ../../modules/nixos/nvidia.nix
    ../../modules/nixos/greetd.nix
    ../../modules/nixos/sway.nix
    ../../modules/nixos/virtualisation.nix
    ../../modules/nixos/android-emulator.nix
  ];

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

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  networking.hostName = "monolith";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Paris";

  services.openssh.enable = true;
  services.xserver.enable = false;
  services.gnome.gnome-keyring.enable = true;

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

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
    users = {
      "ebaron" = import ./home.nix;
    };
  };

  environment.systemPackages = with pkgs; [
    wget
    grim
    slurp
    wl-clipboard
    mako
    xdg-utils
    neovim
  ];
  system.stateVersion = "25.05";
}
