{
  config,
  pkgs,
  inputs,
  user,
  ...
}:

{
  imports = [
    inputs.nix-colors.homeManagerModules.default
    inputs.zen-browser.homeModules.beta
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/rclone.nix
    ../../modules/home-manager/zed.nix
    ../../modules/home-manager/cursor.nix
    ../../modules/home-manager/bash.nix
    ../../modules/home-manager/sway/nomad.nix
    ../../modules/home-manager/zen.nix
    ../../modules/home-manager/foot.nix
  ];

  colorScheme = import ../../themes/nomad.nix;

  home.username = user.username;
  home.homeDirectory = "/home/${user.username}";

  home.stateVersion = "25.05";

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    nodejs
    bun
    gemini-cli
    nixd
    nil
    docker-compose
    figma-linux
    discord
  ];

  home.sessionVariables = {
    PATH = "${config.home.homeDirectory}/.local/bin:$PATH";
    DEFAULT_BROWSER = "zen-browser";
  };

  programs.home-manager.enable = true;
}
