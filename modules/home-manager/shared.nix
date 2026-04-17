{
  config,
  pkgs,
  lib,
  inputs,
  user,
  themeData,
  ...
}:

{
  imports = [
    inputs.nix-colors.homeManagerModules.default
    inputs.zen-browser.homeModules.beta
    inputs.nixvim.homeModules.nixvim
    inputs.spicetify-nix.homeManagerModules.default
    ./git.nix
    ./zed.nix
    ./gtk.nix
    ./shell.nix
    ./desktop/niri.nix
    ./desktop/quickshell
    ./desktop/wofi.nix
    ./desktop/swaync.nix
    ./zen.nix
    ./kitty.nix
    ./neovim.nix
    ./python.nix
    ./spotify.nix
    ./discord.nix
    ./obsidian.nix
    ./audio.nix
  ];

  options.theme.wallpaper = lib.mkOption {
    type = lib.types.path;
    description = "Path to the wallpaper image";
    default = themeData.wallpapers.desktop;
  };

  config = {
    nixpkgs.config.allowUnfree = true;
    colorScheme = {
      inherit (themeData) name slug palette;
    };

    home.username = user.username;
    home.homeDirectory = "/home/${user.username}";

    home.packages = with pkgs; [
      nodejs
      bun
      nixd
      nil
      docker-compose
    ];

    home.sessionVariables = {
      PATH = "${config.home.homeDirectory}/.local/bin:$PATH";
      DEFAULT_BROWSER = "zen-browser";
    };

    programs.home-manager.enable = true;
  };
}
