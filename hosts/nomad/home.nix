{
  config,
  pkgs,
  inputs,
  user,
  ...
}:

{
  nixpkgs.config.allowUnfree = true;

  imports = [
    inputs.nix-colors.homeManagerModules.default
    inputs.zen-browser.homeModules.beta
    inputs.nixvim.homeModules.nixvim
    inputs.spicetify-nix.homeManagerModules.default
    inputs.nixcord.homeModules.nixcord
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/zed.nix
    ../../modules/home-manager/cursor.nix
    ../../modules/home-manager/bash.nix
    ../../modules/home-manager/sway.nix
    ../../modules/home-manager/zen.nix
    ../../modules/home-manager/foot.nix
    ../../modules/home-manager/neovim.nix
    ../../modules/home-manager/python.nix
    ../../modules/home-manager/spotify.nix
    ../../modules/home-manager/discord.nix
  ];

  theme.wallpaper = ./wallpaper.png;
  colorScheme = import ../../themes/nomad.nix;

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
}
