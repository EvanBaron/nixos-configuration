{
  config,
  pkgs,
  inputs,
  user,
  ...
}:

let
  theme = import ../../themes/monolith.nix;
in
{
  imports = [
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/rclone.nix
    (import ../../modules/home-manager/zed.nix { inherit theme; })
    ../../modules/home-manager/bash.nix
    ../../modules/home-manager/sway/monolith.nix
    inputs.zen-browser.homeModules.beta
  ];

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
  programs.zen-browser.enable = true;
}
