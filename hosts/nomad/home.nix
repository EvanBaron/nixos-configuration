{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ../../modules/home-manager/git.nix
    ../../modules/home-manager/rclone.nix
    ../../modules/home-manager/zed.nix
    ../../modules/home-manager/bash.nix
    ../../modules/home-manager/sway/nomad.nix
    inputs.zen-browser.homeModules.beta
  ];

  home.username = "ebaron";
  home.homeDirectory = "/home/ebaron";

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
