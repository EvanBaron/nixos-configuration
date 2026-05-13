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
    type = lib.types.enum [
      "monolith"
      "nomad"
      "remnant"
    ];
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

    programs.nix-ld.enable = true;
    programs.nix-ld.libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      fuse3
      icu
      nss
      openssl
      curl
      expat
      libxml2
      # GUI / Electron requirements
      gtk3
      gdk-pixbuf
      glib
      nspr
      atk
      at-spi2-atk
      libdrm
      libxcb
      libX11
      libXcomposite
      libXdamage
      libXext
      libXfixes
      libXrandr
      libXcursor
      libXinerama
      libXrender
      libgbm
      pango
      cairo
      mesa
      libGL
      wayland
      libpulseaudio
      alsa-lib
      libxcrypt-legacy
      dbus
      libnotify
      libsecret
      libxkbcommon
      at-spi2-core
      cups
      systemd
    ];

    networking.networkmanager.enable = true;
    networking.firewall.allowedTCPPorts = [
      8081
      54321
    ];

    time.timeZone = "Europe/Paris";

    i18n.defaultLocale = "en_US.UTF-8";
    i18n.extraLocaleSettings = {
      LC_ADDRESS = "fr_FR.UTF-8";
      LC_IDENTIFICATION = "fr_FR.UTF-8";
      LC_MEASUREMENT = "fr_FR.UTF-8";
      LC_MONETARY = "fr_FR.UTF-8";
      LC_NAME = "fr_FR.UTF-8";
      LC_NUMERIC = "fr_FR.UTF-8";
      LC_PAPER = "fr_FR.UTF-8";
      LC_TELEPHONE = "fr_FR.UTF-8";
      LC_TIME = "fr_FR.UTF-8";
    };

    services = {
      openssh.enable = true;
      xserver.enable = false;
      gnome.gnome-keyring.enable = true;
      dbus.enable = true;
      dbus.implementation = "broker";
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
