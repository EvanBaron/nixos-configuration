{
  config,
  pkgs,
  inputs,
  ...
}:

{
  imports = [
    ../../modules/home-manager/git.nix
    inputs.zen-browser.homeModules.beta
  ];

  home.username = "ebaron";
  home.homeDirectory = "/home/ebaron";

  home.stateVersion = "25.05";

  home.packages = with pkgs; [
    bun
    gemini-cli
    zed-editor
  ];

  home.file = {

  };

  home.sessionVariables = {
    PATH = "${config.home.homeDirectory}/.local/bin:$PATH";
  };

  programs.home-manager.enable = true;
  programs.zen-browser.enable = true;
}
