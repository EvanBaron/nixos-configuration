{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
{
  imports = [
    inputs.home-manager.nixosModules.default
    ./hardware.nix
    ./user.nix
    ./grub.nix
    ./sddm.nix
    ./niri.nix
    ./docker.nix
    ./android.nix
    ./rust.nix
    ./c.nix
    ./thunar.nix
    ./audio.nix
  ];

  options.activeTheme = lib.mkOption {
    type = lib.types.enum [ "monolith" "nomad" "remnant" ];
    description = "The active theme for this host";
  };

  config = {
    _module.args.themeData = import ../../themes/${config.activeTheme}/palette.nix;

    home-manager = {
      extraSpecialArgs = {
        inherit inputs;
        user = config.user;
        themeData = import ../../themes/${config.activeTheme}/palette.nix;
        mylib = import ../home-manager/lib { inherit pkgs lib; };
      };
      sharedModules = [
        { home.stateVersion = "25.05"; }
      ];
    };

    nixpkgs.config.allowUnfree = true;

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

    programs.dconf.enable = true;

    networking.networkmanager.enable = true;
    networking.firewall.allowedTCPPorts = [
      8081
      54321
    ];

    time.timeZone = "Europe/Paris";

    services = {
      openssh.enable = true;
      xserver.enable = false;
      gnome.gnome-keyring.enable = true;
    };

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

    environment.systemPackages = with pkgs; [
      wget
      grim
      slurp
      wl-clipboard
      xdg-utils
    ];

    system.stateVersion = "25.05";
  };
}
