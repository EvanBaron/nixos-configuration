{
  pkgs,
  inputs,
  ...
}:
{
  nixpkgs.config.allowUnfree = true;

  imports = [
    inputs.home-manager.nixosModules.default
    ./user.nix
    ./grub.nix
    ./sddm.nix
    ./sway.nix
    ./docker.nix
    ./android.nix
    ./rust.nix
    ./c.nix
    ./thunar.nix
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Automatic Nix garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  networking.networkmanager.enable = true;
  networking.firewall.allowedTCPPorts = [ 8081 ];

  time.timeZone = "Europe/Paris";

  services = {
    openssh.enable = true;
    xserver.enable = false;
    gnome.gnome-keyring.enable = true;
  };

  environment.etc."wayland-sessions/sway.desktop".text = ''
    [Desktop Entry]
    Name=Sway
    Comment=An i3-compatible Wayland compositor
    Exec=sway --unsupported-gpu
    Type=Application
    Keywords=tiling;wm;windowmanager;wayland;compositor;
  '';

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

  home-manager = {
    extraSpecialArgs = { inherit inputs; };
  };

  environment.systemPackages = with pkgs; [
    wget
    grim
    slurp
    wl-clipboard
    xdg-utils
  ];

  home-manager.sharedModules = [
    { home.stateVersion = "25.05"; }
  ];

  system.stateVersion = "25.05";
}
